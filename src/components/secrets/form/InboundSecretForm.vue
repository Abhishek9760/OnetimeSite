<template>
  <div>
    <h3>{{ title }}</h3>

    <form id="createSecret"
          method="post"
          autocomplete="off"
          action="/incoming"
          class="space-y-6">
      <input type="hidden"
            name="shrimp"
            :value="csrfStore.shrimp" />
      <div>
        <textarea rows="7"
                  class="w-full px-3 py-2 border rounded-lg text-lg
                  focus:outline-none focus:ring-brandcomp-500 focus:border-brandcomp-500
                  text-gray-700 dark:text-gray-300 dark:bg-gray-700 dark:border-gray-600
                  transition duration-150 ease-in-out"
                  name="secret"
                  autocomplete="off"
                  :placeholder="$t('web.incoming.incoming_secret_placeholder')"></textarea>
      </div>

      <div class="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('web.incoming.incoming_secret_options') }}
        </h3>

        <div class="space-y-4">
          <div>
            <label for="ticketnoField"
                  class="block font-medium text-gray-700 dark:text-gray-300">
              <svg class="w-5 h-5 inline-block mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"></path>
              </svg>
              {{ $t('web.incoming.incoming_ticket_number') }}:
            </label>
            <input type="text"
                  name="ticketno"
                  id="ticketnoField"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm
                  focus:ring-brandcomp-500 focus:border-brandcomp-500
                  dark:bg-gray-600 dark:border-gray-500 dark:text-white
                  transition duration-150 ease-in-out"
                  :placeholder="$t('web.incoming.incoming_ticket_number_hint')"
                  required
                  autocomplete="off" />
          </div>

          <div>
            <label for="recipientField"
                  class="block font-medium text-gray-700 dark:text-gray-300">
              <svg class="w-5 h-5 inline-block mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
              </svg>
              {{ $t('web.incoming.incoming_recipient_address') }}:
            </label>
            <div class="mt-1 text-gray-900 dark:text-gray-100">{{ incoming_recipient }}</div>
          </div>
        </div>
      </div>

      <button type="submit"
              name="kind"
              value="share"
              :disabled="isLoading"
              class="w-full flex justify-center items-center py-2 px-4 border border-transparent rounded-md shadow-sm font-semibold text-lg
              text-white bg-brand-600 hover:bg-brand-700
              focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500
              dark:bg-brand-500 dark:hover:bg-brand-600 dark:focus:ring-offset-gray-800
              disabled:opacity-50 disabled:cursor-not-allowed
              transition duration-150 ease-in-out">
        <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span v-if="!isLoading">{{ $t('web.incoming.incoming_button_create') }}</span>
        <span v-else>{{ $t('web.incoming.incoming_button_creating') }}</span>
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { useCsrfStore } from '@/stores/csrfStore';
import { useWindowProps } from '@/composables/useWindowProps';
import { ref } from 'vue';

const csrfStore = useCsrfStore();
const isLoading = ref(false);

export interface Props {
  enabled?: boolean;
  title: string;
}

withDefaults(defineProps<Props>(), {
  enabled: true,
})

const {incoming_recipient} = useWindowProps(['incoming_recipient']);


</script>

<style scoped>

</style>
