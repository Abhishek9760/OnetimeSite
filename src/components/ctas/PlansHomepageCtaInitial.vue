<template>
  <section
           class="max-w-4xl mx-auto my-12 bg-white dark:bg-gray-800 rounded-lg shadow-md overflow-hidden transition-colors duration-300">
    <div class="p-8 flex flex-col md:flex-row items-start justify-between relative">

      <div class="w-full md:w-2/3 md:pr-8">
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white mb-4 flex items-center">
          <svg class="w-8 h-8 mr-3 text-brand-500"
               fill="none"
               stroke="currentColor"
               height="20"
               width="20"
               viewBox="0 0 24 24"
               xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
            </path>
          </svg>
          {{ $t('web.page.cta_title') }}
        </h2>
        <p class="text-gray-600 dark:text-gray-300 mb-6">{{ $t('web.page.cta_subtitle') }}</p>
        <ul class="space-y-3 text-sm text-gray-600 dark:text-gray-300 mb-8">
          <li class="flex items-center">
            <svg class="h-5 w-5 mr-3 text-brand-500"
                 fill="none"
                 stroke="currentColor"
                 height="20"
                 width="20"
                 viewBox="0 0 24 24"
                 xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"></path>
            </svg>
            {{ $t('web.page.cta_feature1') }}
          </li>
          <li class="flex items-center">
            <svg class="h-5 w-5 mr-3 text-brand-500"
                 fill="none"
                 stroke="currentColor"
                 height="20"
                 width="20"
                 viewBox="0 0 24 24"
                 xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"></path>
            </svg>
            {{ $t('web.page.cta_feature2') }}
          </li>
          <li class="flex items-center">
            <svg class="h-5 w-5 mr-3 text-brand-500"
                 fill="none"
                 stroke="currentColor"
                 height="20"
                 width="20"
                 viewBox="0 0 24 24"
                 xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"></path>
            </svg>
            {{ $t('web.page.cta_feature3') }}
          </li>
        </ul>
        <router-link to="/pricing"
                     class="font-brand inline-flex items-center px-6 py-3 bg-brand-600 text-white font-semibold rounded-md hover:bg-brand-700 transition duration-300">
          {{ $t('web.page.explore_premium_plans') }}
          <svg class="ml-2 w-4 h-4"
               fill="none"
               stroke="currentColor"
               height="20"
               width="20"
               viewBox="0 0 24 24"
               xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"></path>
          </svg>
        </router-link>
      </div>
      <div class="w-full md:w-1/3 md:border-l md:border-gray-200 dark:md:border-gray-700 md:pl-8 mt-20 md:mt-20">
        <p class="text-gray-600 dark:text-gray-300 mb-4">{{ $t('web.page.need_free_account') }}</p>

        <router-link to="/signup"
                     class="font-brand inline-block w-full text-base text-center px-6 py-3 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-white font-semibold rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition duration-300">
          {{ $t('web.page.sign_up_free') }}
        </router-link>

      </div>
    </div>
  </section>

</template>

<script setup lang="ts">
  defineProps<{
    ariaLabel: string;
  }>();
</script>
