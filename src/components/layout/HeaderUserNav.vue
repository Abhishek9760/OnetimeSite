<template>
  <div class="hidden sm:flex items-center">
    <router-link to="/"
                 class="text-gray-400 hover:text-gray-300 transition group">
      <span id="userEmail"
            :class="{ 'animate-pulse': isNewFeature }"
            class="group-hover:text-gray-300">
        {{ cust.custid }}
      </span>

    </router-link>

    <FancyIcon v-if="domains_enabled && !planAllowsCustomDomains"
               to="/pricing"
               ariaLabel="Click this lightning bolt to upgrade for custom domains" />

    <router-link v-if="colonel"
                 to="/colonel/"
                 title=""
                 class="ml-2 text-gray-400 hover:text-gray-300 transition">
      <Icon icon="mdi:star"
            class="w-4 h-4" />
    </router-link>
    <span class="mx-2 text-gray-400">|</span>
  </div>

</template>

<script setup lang="ts">
import FancyIcon from '@/components/ctas/FancyIcon.vue';
import { useWindowProps } from '@/composables/useWindowProps';
import { Customer } from '@/types/onetime';
import { Icon } from '@iconify/vue';
import { ref, computed } from 'vue';
const { domains_enabled, plan } = useWindowProps(['authenticated', 'metadata_record_count', 'domains_enabled', 'plan', 'custom_domains_record_count']);

const planAllowsCustomDomains = computed(() => plan.value.options?.custom_domains === true);

// Allows for highlighting feature to user just one
// time to false after user has seen it once. Setting
// to false disables altogether but defaulting to true
// and flipping a localStorage flag to false after user
// has seen it once is a good way to handle this.
const isNewFeature = ref(false)

defineProps<{
  cust: Customer;
  colonel?: boolean;

}>();

</script>

<style>
@keyframes pulse {

  0%,
  100% {
    opacity: 1;
  }

  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
