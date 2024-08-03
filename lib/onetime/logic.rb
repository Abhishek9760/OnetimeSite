require 'stathat'
require 'timeout'

require_relative 'logic/base'

module Onetime
  module Logic

    class ReceiveFeedback < OT::Logic::Base
      attr_reader :msg
      def process_params
        @msg = params[:msg].to_s.slice(0, 999)
      end

      def raise_concerns
        limit_action :send_feedback
        raise_form_error "You need an account to do that" if cust.anonymous?
        if @msg.empty? || @msg =~ /#{Regexp.escape("question or comment")}/
          raise_form_error "You can be more original than that!"
        end
      end

      def process
        @msg = "#{msg} [%s]" % [cust.anonymous? ? sess.ipaddress : cust.custid]
        OT.ld [:receive_feedback, msg].inspect
        OT::Feedback.add @msg
        sess.set_info_message "Message received. Send as much as you like!"
      end
    end

    class CreateAccount < OT::Logic::Base
      attr_reader :cust, :plan, :autoverify, :customer_role
      attr_reader :planid, :custid, :password, :password2, :skill
      attr_accessor :token
      def process_params
        @planid = params[:planid].to_s
        @custid = params[:u].to_s.downcase.strip

        @password = self.class.normalize_password(params[:p])
        @password2 = self.class.normalize_password(params[:p2])

        @autoverify = OT.conf&.dig(:site, :authentication, :autoverify) || false

        # This is a hidden field, so it should be empty. If it has a value, it's
        # a simple bot trying to submit the form or similar chicanery. We just
        # quietly redirect to the home page to mimic a successful response.
        @skill = params[:skill].to_s.strip.slice(0,60)
      end

      def raise_concerns
        limit_action :create_account
        raise OT::FormError, "You're already signed up" if sess.authenticated?
        raise_form_error "Username not available" if OT::Customer.exists?(custid)
        raise_form_error "Is that a valid email address?" unless valid_email?(custid)
        raise_form_error "Passwords do not match" unless password == password2
        raise_form_error "Password is too short" unless password.size >= 6
        raise_form_error "Unknown plan type" unless OT::Plan.plan?(planid)

        # This is a hidden field, so it should be empty. If it has a value, it's
        # a simple bot trying to submit the form or similar chicanery. We just
        # quietly redirect to the home page to mimic a successful response.
        unless skill.empty?
          raise OT::Redirect.new('/?s=1') # the query string is just an arbitrary value for the logs
        end
      end
      def process


        @plan = OT::Plan.plan(planid)
        @cust = OT::Customer.create custid

        cust.update_passphrase password
        sess.update_fields(custid: cust.custid)

        @customer_role = if OT.conf[:colonels].member?(cust.custid)
                           'colonel'
                         else
                           'customer'
                         end

        cust.update_fields(planid: @plan.planid, verified: @autoverify.to_s, role: @customer_role)

        OT.info "[new-customer] #{cust.custid} #{cust.role} #{sess.ipaddress} #{plan.planid} #{sess.short_identifier}"
        OT::Logic.stathat_count("New Customers (OTS)", 1)

        if autoverify
          sess.set_info_message "Account created"
        else
          self.send_verification_email
        end

      end

      private

      def send_verification_email
        _, secret = Onetime::Secret.spawn_pair cust.custid, [sess.external_identifier], token

        msg = "Thanks for verifying your account. We got you a secret fortune cookie!\n\n\"%s\"" % OT::Utils.random_fortune

        secret.encrypt_value msg
        secret.verification = true
        secret.custid = cust.custid
        secret.save

        view = OT::App::Mail::Welcome.new cust, locale, secret

        begin
          view.deliver_email self.token

        rescue StandardError => ex
          errmsg = "Couldn't send the verification email. Let us know below."
          OT.le "Error sending verification email: #{ex.message}"
          sess.set_info_message errmsg
        end
      end

      def form_fields
        { :planid => planid, :custid => custid }
      end
    end

    class AuthenticateSession < OT::Logic::Base
      attr_reader :custid, :stay, :greenlighted
      attr_reader :session_ttl

      def process_params
        @potential_custid = params[:u].to_s.downcase.strip
        @passwd = self.class.normalize_password(params[:p])
        #@stay = params[:stay].to_s == "true"
        @stay = true # Keep sessions alive by default
        @session_ttl = (stay ? 30.days : 20.minutes).to_i
        if @potential_custid.to_s.index(':as:')
          @colonelname, @potential_custid = *@potential_custid.downcase.split(':as:')
        else
          @potential_custid = @potential_custid.downcase if @potential_custid
        end
        if @passwd.to_s.empty?
          @cust = nil
        elsif @colonelname && OT::Customer.exists?(@colonelname) && OT::Customer.exists?(@potential_custid)
          OT.info "[login-as-attempt] #{@colonelname} as #{@potential_custid} #{@sess.ipaddress}"
          potential = OT::Customer.load @colonelname
          @colonel = potential if potential.passphrase?(@passwd)
          @cust = OT::Customer.load @potential_custid if @colonel.role?(:colonel)
          sess['authenticated_by'] = @colonel.custid
          OT.info "[login-as-success] #{@colonelname} as #{@potential_custid} #{@sess.ipaddress}"
        elsif (potential = OT::Customer.load(@potential_custid))
          @cust = potential if potential.passphrase?(@passwd)
        end
      end

      def raise_concerns
        limit_action :authenticate_session
        if @cust.nil?
          @cust ||= OT::Customer.anonymous
          raise_form_error "Try again"
        end
      end

      def process
        if success?
          @greenlighted = true

          OT.info "[login-success] #{sess.short_identifier} #{cust.obscure_email} #{cust.role} (replacing sessid)"

          # Create a completely new session, new id, new everything (incl
          # cookie which the controllor will implicitly do above when it
          # resends the cookie with the new session id).
          sess.replace!

          OT.info "[login-success] #{sess.short_identifier} #{cust.obscure_email} #{cust.role} (new sessid)"

          sess.update_fields :custid => cust.custid, :authenticated => 'true'
          sess.ttl = session_ttl if @stay
          sess.save
          cust.save

          if OT.conf[:colonels].member?(cust.custid)
            cust.role = :colonel
          else
            cust.role = :customer unless cust.role?(:customer)
          end
        else
          raise_form_error "Try again"
        end
      end

      def success?
        !cust&.anonymous? && (cust.passphrase?(@passwd) || @colonel&.passphrase?(@passwd))
      end

      private
      def form_fields
        {:custid => custid}
      end
    end

    class DestroySession < OT::Logic::Base
      def process_params
      end
      def raise_concerns
        limit_action :destroy_session
        OT.info "[destroy-session] #{@custid} #{@sess.ipaddress}"
      end
      def process
        sess.destroy!
      end
    end

    class Dashboard < OT::Logic::Base
      def process_params
      end
      def raise_concerns
        limit_action :dashboard
      end
      def process
      end
    end

    class CreateSecret < OT::Logic::Base
      attr_reader :passphrase, :secret_value, :kind, :ttl, :recipient, :recipient_safe, :maxviews
      attr_reader :metadata, :secret
      attr_accessor :token
      def process_params
        @ttl = params[:ttl].to_i
        @ttl = plan.options[:ttl] if @ttl <= 0
        @ttl = plan.options[:ttl] if @ttl >= plan.options[:ttl]
        @ttl = 5.minutes if @ttl < 1.minute
        @maxviews = params[:maxviews].to_i
        @maxviews = 1 if @maxviews < 1
        @maxviews = (plan.options[:maxviews] || 100) if @maxviews > (plan.options[:maxviews] || 100)  # TODO
        if ['share', 'generate'].member?(params[:kind].to_s)
          @kind = params[:kind].to_s.to_sym
        end
        @secret_value = kind == :share ? params[:secret] : Onetime::Utils.strand(12)
        @passphrase = params[:passphrase].to_s
        params[:recipient] = [params[:recipient]].flatten.compact.uniq
        r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
        @recipient = params[:recipient].collect { |email_address|
          next if email_address.to_s.empty?
          email_address.scan(r).uniq.first
        }.compact.uniq
        @recipient_safe = recipient.collect { |r| OT::Utils.obscure_email(r) }
      end
      def raise_concerns
        limit_action :create_secret
        limit_action :email_recipient unless recipient.empty?
        if kind == :share && secret_value.to_s.empty?
          raise_form_error "You did not provide anything to share" #
        end
        if cust.anonymous? && !@recipient.empty?
          raise_form_error "An account is required to send emails. Signup here: https://#{OT.conf[:site][:host]}"
        end
        raise OT::Problem, "Unknown type of secret" if kind.nil?
      end
      def process
        @metadata, @secret = Onetime::Secret.spawn_pair cust.custid, [sess.external_identifier], token
        if !passphrase.empty?
          secret.update_passphrase passphrase
          metadata.passphrase = secret.passphrase
        end
        secret.encrypt_value secret_value, :size => plan.options[:size]
        metadata.ttl, secret.ttl = ttl*2, ttl
        metadata.secret_shortkey = secret.shortkey
        metadata.secret_ttl = secret.ttl
        secret.maxviews = maxviews
        secret.save
        metadata.save
        if metadata.valid? && secret.valid?
          unless cust.anonymous?
            cust.add_metadata metadata
            cust.incr :secrets_created
          end
          OT::Customer.global.incr :secrets_created
          unless recipient.nil? || recipient.empty?
            klass = OT::App::Mail::SecretLink
            metadata.deliver_by_email cust, locale, secret, recipient.first, klass
          end
          OT::Logic.stathat_count("Secrets", 1)
        else
          raise_form_error "Could not store your secret"
        end
      end
      def redirect_uri
        ['/private/', metadata.key].join
      end
      private
      def form_fields
      end
    end

    class CreateIncoming < OT::Logic::Base
      attr_reader :passphrase, :secret_value, :ticketno
      attr_reader :metadata, :secret, :recipient, :ttl
      attr_accessor :token
      def process_params
        @ttl = 7.days
        @secret_value = params[:secret]
        @ticketno = params[:ticketno].strip
        @passphrase = OT.conf[:incoming][:passphrase].strip
        params[:recipient] = [OT.conf[:incoming][:email]]
        r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
        @recipient = params[:recipient].collect { |email_address|
          next if email_address.to_s.empty?

          email_address.scan(r).uniq.first
        }.compact.uniq
      end
      def raise_concerns
        limit_action :create_secret
        limit_action :email_recipient unless recipient.empty?
        regex = Regexp.new(OT.conf[:incoming][:regex] || '\A[a-zA-Z0-9]{1,32}\z')
        if secret_value.to_s.empty?
          raise_form_error "You did not provide any information to share"
        end
        if ticketno.to_s.empty? || !ticketno.match(regex)
          raise_form_error "You must provide a valid ticket number"
        end
      end
      def process
        @metadata, @secret = Onetime::Secret.spawn_pair cust.custid, [sess.external_identifier], token
        if !passphrase.empty?
          secret.update_passphrase passphrase
          metadata.passphrase = secret.passphrase
        end
        secret.encrypt_value secret_value, :size => plan.options[:size]
        metadata.ttl, secret.ttl = ttl, ttl
        metadata.secret_shortkey = secret.shortkey
        secret.save
        metadata.save
        if metadata.valid? && secret.valid?
          unless cust.anonymous?
            cust.add_metadata metadata
            cust.incr :secrets_created
          end
          OT::Customer.global.incr :secrets_created
          unless recipient.nil? || recipient.empty?
            metadata.deliver_by_email cust, locale, secret, recipient.first, OT::App::Mail::IncomingSupport, ticketno
          end
          OT::Logic.stathat_count("Secrets", 1)
        else
          raise_form_error "Could not store your secret"
        end
      end
    end

    class ShowSecret < OT::Logic::Base
      attr_reader :key, :passphrase, :continue
      attr_reader :secret, :show_secret, :secret_value, :truncated, :original_size, :verification, :correct_passphrase
      def process_params
        @key = params[:key].to_s
        @secret = Onetime::Secret.load key
        @passphrase = params[:passphrase].to_s
        @continue = params[:continue] == 'true'
      end
      def raise_concerns
        limit_action :show_secret
        raise OT::MissingSecret if secret.nil? || !secret.viewable?
      end
      def process
        @correct_passphrase = !secret.has_passphrase? || secret.passphrase?(passphrase)
        @show_secret = secret.viewable? && correct_passphrase && continue
        @verification = secret.verification.to_s == "true"
        owner = secret.load_customer
        if show_secret
          @secret_value = secret.can_decrypt? ? secret.decrypted_value : secret.value
          @truncated = secret.truncated
          @original_size = secret.original_size
          if verification
            if cust.anonymous? || (cust.custid == owner.custid && !owner.verified?)
              owner.verified = "true"
              sess.destroy!
              secret.received!
            else
              raise_form_error "You can't verify an account when you're already logged in."
            end
          else
            owner.incr :secrets_shared unless owner.anonymous?
            OT::Customer.global.incr :secrets_shared
            secret.received!
            OT::Logic.stathat_count("Viewed Secrets", 1)
          end
        elsif !correct_passphrase
          limit_action :failed_passphrase if secret.has_passphrase?
          # do nothing
        end
      end
    end

    class ShowMetadata < OT::Logic::Base
      attr_reader :key
      attr_reader :metadata, :secret, :show_secret
      def process_params
        @key = params[:key].to_s
        @metadata = Onetime::Metadata.load key
      end
      def raise_concerns
        limit_action :show_metadata
        raise OT::MissingSecret if metadata.nil?
      end
      def process
        @secret = @metadata.load_secret
      end
    end

    class BurnSecret < OT::Logic::Base
      attr_reader :key, :passphrase, :continue
      attr_reader :metadata, :secret, :correct_passphrase, :greenlighted

      def process_params
        @key = params[:key].to_s
        @metadata = Onetime::Metadata.load key
        @passphrase = params[:passphrase].to_s
        @continue = params[:continue] == 'true'
      end

      def raise_concerns
        limit_action :burn_secret
        raise OT::MissingSecret if metadata.nil?
      end

      def process
        @secret = @metadata.load_secret
        if secret
          @correct_passphrase = !secret.has_passphrase? || secret.passphrase?(passphrase)
          @greenlighted = secret.viewable? && correct_passphrase && continue
          owner = secret.load_customer
          if greenlighted
            owner.incr :secrets_burned unless owner.anonymous?
            OT::Customer.global.incr :secrets_burned
            secret.burned!
            OT::Logic.stathat_count('Burned Secrets', 1)
          elsif !correct_passphrase
            limit_action :failed_passphrase if secret.has_passphrase?
            # do nothing
          end
        end
      end

    end

    class ShowRecentMetadata < OT::Logic::Base
      attr_reader :metadata
      def process_params
        @metadata = cust.metadata
      end
      def raise_concerns
        limit_action :show_metadata
        raise OT::MissingSecret if metadata.nil?
      end
      def process
      end
    end

  end
end

require_relative 'logic/account'
