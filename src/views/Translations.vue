
<template>

  <div>
    <GithubCorner />

    <article class="prose dark:prose-invert lg:prose-lg xl:prose-xl">
      <h2 class="text-3xl font-bold mb-4 text-brand-500 dark:text-brand-400">Help us translate!</h2>

      <p class="mb-4">
        Since Onetime Secret launched in 2012, one of the most requested features has been to support
        languages other than english. Many visitors -- in fact, most -- live in countries where
        English is not the first or even second language.
      </p>

      <p class="mb-4">
        One of the major goals of Onetime Secret is to simplify secure communication so that it can
        help as many people as possible. Translating the site plays a big role in that. Since 2015 our
        contributors have added over 20, plus corrections and other updates! But we still have a ways
        to go.
        <strong class="text-brand-500 dark:text-brand-400">
          I need your help to add support for more languages.
        </strong>
      </p>

      <div class="mt-8 text-center">
        <a href="https://github.com/onetimesecret/onetimesecret"
          class="bg-white hover:bg-brand-50 text-brand-500 font-bold py-2 px-4 rounded inline-flex items-center"
          target="_blank"
          rel="noopener noreferrer">
          <svg class="w-4 h-4 mr-2"
              fill="currentColor"
              viewBox="0 0 24 24"
              width="20"
              height="20"
              xmlns="http://www.w3.org/2000/svg">
            <path
                  d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" />
          </svg>
          Fork on GitHub and Submit a PR
        </a>
      </div>

      <hr class="my-8" />

      <h3 class="text-2xl font-semibold mb-4">Translations</h3>
      <p class="mb-4">
        The following people have donated their time to help expand the reach of Onetime Secret:
      </p>

      <div v-for="translation in translations" :key="translation['code']">
        <h4 class="text-xl font-semibold mb-2">
          {{ translation['name'] }}
          (<a @click.prevent="changeLocale(translation['code'])"
          href="#"
          class="text-brand-500 dark:text-brand-400 hover:underline cursor-pointer">switch</a>)
        </h4>
        <ul class="list-disc pl-5 mb-4">
          <li v-for="(translator, index) in translation['translators']" :key="`${translation['code']}-${index}}`">
            <a v-if="translator['url']" :href="translator['url']"
              class="text-brand-500 dark:text-brand-400 hover:underline">{{ translator['name'] }}</a>
            <span v-else>{{ translator['name'] }}</span>
            ({{ translator['date'] }})
          </li>
        </ul>
      </div>

      <hr class="my-8" />

      <p class="mb-4">
        If you have a Github account, you can use the links above to create a new language file. If
        not, you can copy the text from an existing lanaguage -- like
        <a href="https://github.com/onetimesecret/onetimesecret/blob/develop/etc/locale/en"
          class="text-brand-500 dark:text-brand-400 hover:underline">english</a>
        -- and send a text file via email to
        <EmailObfuscator
          email="contribute@onetimesecret.com"
          subject="Translations"
        />.
      </p>

      <p class="mb-4">
        There is a feedback form at the bottom of the page if you have any questions. If you're not
        logged in, be sure to include an email address so I can reply.
      </p>

      <p class="mb-4">Delano</p>
    </article>
  </div>

</template>

<script setup lang="ts">
import translations from '@/sources/translations.json';
import GithubCorner from '@/components/GithubCorner.vue';
import EmailObfuscator from '@/components/EmailObfuscator.vue';
import { setLanguage } from '@/i18n';
import { useLanguageStore } from '@/stores/languageStore';

const languageStore = useLanguageStore();

const changeLocale = async (newLocale: string) => {
  if (languageStore.getSupportedLocales.includes(newLocale)) {
    try {
      await languageStore.updateLanguage(newLocale);
      await setLanguage(newLocale);
    } catch (err) {
      console.error('Failed to update language:', err);
    }
  }
};
</script>
