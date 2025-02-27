<template>
  <div class="flex items-center relative">
    <button
      type="button"
      class="inline-flex items-center justify-center w-full rounded-md border
           border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-sm font-medium
           text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700
           focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 dark:focus:ring-offset-gray-900 focus:ring-indigo-500"
      :aria-expanded="isMenuOpen"
      aria-haspopup="true"
      @click="toggleMenu"
      @keydown.down.prevent="openMenu"
      @keydown.enter.prevent="openMenu"
      @keydown.space.prevent="openMenu">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129" />
      </svg>
      {{ currentLocale }}
      <svg class="ml-2 -mr-1 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    </button>

    <div
      v-if="isMenuOpen"
      class="absolute right-0 bottom-full mb-2 w-56 rounded-md shadow-lg
           bg-white dark:bg-gray-800 ring-1 ring-black ring-opacity-5
           dark:ring-white dark:ring-opacity-20 focus:outline-none z-[100]"
      role="menu"
      aria-orientation="vertical"
      @keydown.esc="closeMenu"
      @keydown.up.prevent="focusPreviousItem"
      @keydown.down.prevent="focusNextItem">
      <div class="py-1 max-h-60 overflow-y-auto" role="none">
        <a
          v-for="locale in supportedLocales"
          :key="locale"
          href="#"
          @click.prevent="changeLocale(locale)"
          :class="[
            'block px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100',
            locale === currentLocale ? 'text-indigo-600 dark:text-indigo-400 font-bold bg-gray-100 dark:bg-gray-700' : 'text-gray-700 dark:text-gray-300'
          ]"
          role="menuitem">
          {{ locale }}
        </a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, onUnmounted } from 'vue';
import { setLanguage } from '@/i18n';
import { useLanguageStore } from '@/stores/languageStore';
import { useWindowProp } from '@/composables/useWindowProps.js';

const emit = defineEmits(['localeChanged', 'menuToggled']);

const languageStore = useLanguageStore();
const supportedLocales = languageStore.getSupportedLocales;

// Use window.locale if available, otherwise fallback to store value
const cust = useWindowProp('cust');

const selectedLocale = ref(languageStore.determineLocale(cust?.value?.locale));

const currentLocale = computed(() => selectedLocale.value);

const isMenuOpen = ref(false);
const menuItems = ref<HTMLElement[]>([]);

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
  emit('menuToggled', isMenuOpen.value);
};

const openMenu = () => {
  isMenuOpen.value = true;
  emit('menuToggled', isMenuOpen.value);
};

const closeMenu = () => {
  isMenuOpen.value = false;
  emit('menuToggled', isMenuOpen.value);
};

const focusNextItem = () => {
  const currentIndex = menuItems.value.indexOf(document.activeElement as HTMLElement);
  const nextIndex = (currentIndex + 1) % menuItems.value.length;
  menuItems.value[nextIndex].focus();
};

const focusPreviousItem = () => {
  const currentIndex = menuItems.value.indexOf(document.activeElement as HTMLElement);
  const previousIndex = (currentIndex - 1 + menuItems.value.length) % menuItems.value.length;
  menuItems.value[previousIndex].focus();
};

const changeLocale = async (newLocale: string) => {
  if (languageStore.getSupportedLocales.includes(newLocale)) {
    try {
      if (cust.value) {
        cust.value.locale = newLocale;
      }
      await languageStore.updateLanguage(newLocale);
      await setLanguage(newLocale);
      selectedLocale.value = newLocale; // Update the selectedLocale
      emit('localeChanged', newLocale);
    } catch (err) {
      console.error('Failed to update language:', err);
    } finally {
      closeMenu();
    }
  }
};

const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement;
  if (!target.closest('.relative')) {
    closeMenu();
  }
};

const handleEscapeKey = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    closeMenu();
  }
};

onMounted(() => {
  menuItems.value = Array.from(document.querySelectorAll('[role="menuitem"]')) as HTMLElement[];

  // Ensure that the i18n system is updated if the
  // customer.locale value is different from the current locale.
  setLanguage(selectedLocale.value);

  // Add event listeners for click outside and escape key
  document.addEventListener('click', handleClickOutside);
  document.addEventListener('keydown', handleEscapeKey);
});

onUnmounted(() => {
  // Remove event listeners when component is unmounted
  document.removeEventListener('click', handleClickOutside);
  document.removeEventListener('keydown', handleEscapeKey);
});
</script>
