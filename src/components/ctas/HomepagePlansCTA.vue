<template>
  <div class="w-full bg-gray-100 dark:bg-gray-800 border-t border-b border-gray-200 dark:border-gray-700 mb-6">
    <div class="container mx-auto py-2 px-4">
      <div class="flex flex-col md:flex-row items-center justify-between">
        <div class="flex items-center space-x-3 mb-0 md:mb-0">
          <svg class="sm:w-8 sm:h-8 md:w-5 md:h-5 w-12 h-12 text-brand-500 hidden sm:block"
               fill="none"
               stroke="currentColor"
               viewBox="0 0 24 24"
               xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24">
            <path stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
            </path>
          </svg>
          <span
                class="text-lg md:text-sm font-semibold font-brand text-gray-700 dark:text-gray-300 uppercase hidden sm:block">
            {{ $t('web.homepage.cta_title') }}
          </span>
        </div>
        <div class="flex w-full sm:w-auto font-brand">
          <router-link to="/pricing"
                       class="w-full sm:w-auto inline-flex items-center justify-center px-6 py-4 sm:py-2 md:px-4
              md:py-1 text-xl sm:text-base md:text-xs font-semibold text-brand-500 bg-white
              hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500
              rounded-md border border-brand-500 transition duration-150 animate-throb
              dark:text-white dark:bg-brand-500 dark:hover:bg-brand-600">
            <span class="sm:hidden">Now with custom domains</span>
            <span class="hidden sm:inline">{{ $t('web.homepage.explore_premium_plans') }}</span>
            <svg class="ml-2 w-5 h-5 md:w-4 md:h-4"
                 fill="none"
                 stroke="currentColor"
                 viewBox="0 0 24 24"
                 width="24"
                 height="24"
                 xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"></path>
            </svg>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
@keyframes throb {

  0%,
  100% {
    transform: scale(1);
  }

  50% {
    transform: scale(1.05);
  }

}

.animate-throb {
  animation: throb 2s ease-in-out infinite;
}
</style>
