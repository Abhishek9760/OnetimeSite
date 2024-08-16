
class Onetime::EmailReceipt < Familia::Horreum
  include Gibbler::Complex

  db 8
  ttl 30.days
  prefix :secret
  identifier :secretid
  suffix :email

  class_sorted_set :values, key: 'onetime:emailreceipt'

  field :custid
  field :secretid
  field :message_response

  # e.g.
  #
  #  secret:1234567890:email
  #
  #def initialize custid=nil, secretid=nil, message_response=nil
  #  @prefix = :secret
  #  @suffix = :email
  #  @custid = custid
  #  @secretid = secretid
  #  @custid = custid.identifier if custid.is_a?(Familia::RedisObject)
  #  @secretid = secretid.identifier if secretid.is_a?(Familia::RedisObject)
  #  @message_response = message_response
  #  super name, db: 8, ttl: 30.days
  #end

  def destroy! *args
    super
    # Remove
    OT::EmailReceipt.values.rem identifier
  end

  module ClassMethods
    attr_reader :values

    # fobj is a familia object
    def add fobj
      self.values.add OT.now.to_i, fobj.identifier
      self.values.remrangebyscore 0, OT.now.to_i-2.days
    end

    def all
      self.values.revrangeraw(0, -1).collect { |identifier| load(identifier) }
    end

    def recent duration=48.hours
      spoint, epoint = OT.now.to_i-duration, OT.now.to_i
      self.values.rangebyscoreraw(spoint, epoint).collect { |identifier| load(identifier) }
    end

    def exists? fobjid
      fobj = new fobjid
      fobj.exists?
    end

    def load fobjid
      fobj = new fobjid
      fobj.exists? ? fobj : nil
    end

    def create(custid, secretid, message_response=nil)
      fobj = new custid, secretid, message_response
      OT.ld "[EmailReceipt.create] #{custid} #{secretid} #{message_response}"
      raise ArgumentError, "#{name} record exists #{rediskey}" if fobj.exists?

      fobj.update_fields custid: custid, secretid: secretid, message_response: message_response
      add fobj # to the @values sorted set
      fobj
    end

  end

  extend ClassMethods
end
