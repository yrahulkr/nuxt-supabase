<script setup lang="ts">
const client = useSupabaseClient()
const user = useSupabaseUser()
const colorMode = useColorMode()

// Handle hydration mismatch by using a mounted state
const isMounted = ref(false)

const logout = async () => {
  await client.auth.signOut()
  navigateTo('/login')
}

const toggleColorMode = () => {
  colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
}

onMounted(() => {
  isMounted.value = true
})
</script>

<template>
  <header class="border-b border-gray-200 dark:border-gray-800 bg-white/75 dark:bg-gray-900/75 backdrop-blur-md sticky top-0 z-50">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="flex h-16 items-center justify-between">
        <!-- Left side -->
        <div class="flex items-center space-x-4">
          <NuxtLink to="/" class="flex items-center space-x-2">
            <div class="w-8 h-8 bg-emerald-500 rounded-lg flex items-center justify-center">
              <UIcon name="i-lucide-check-square" class="w-5 h-5 text-white" />
            </div>
            <span class="font-semibold text-gray-900 dark:text-white">Todo App</span>
          </NuxtLink>
          
          <div class="hidden md:flex items-center space-x-2">
            <UButton
              label="Source"
              target="_blank"
              variant="ghost"
              color="neutral"
              to="https://github.com/nuxt-modules/supabase/tree/main/demo"
              icon="i-lucide-external-link"
              size="sm"
            />
            <UButton
              label="Hosted on Vercel"
              target="_blank"
              variant="ghost"
              color="neutral"
              to="https://vercel.com"
              icon="i-lucide-external-link"
              size="sm"
              class="hidden sm:flex"
            />
          </div>
        </div>

        <!-- Right side -->
        <div class="flex items-center space-x-2">
          <UButton
            variant="ghost"
            size="sm"
            square
            @click="toggleColorMode"
            :aria-label="isMounted && colorMode.value === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'"
          >
            <UIcon 
              :name="isMounted && colorMode.value === 'dark' ? 'i-lucide-sun' : 'i-lucide-moon'" 
              class="w-5 h-5" 
            />
          </UButton>

          <UButton
            v-if="user"
            variant="ghost"
            color="neutral"
            size="sm"
            @click="logout"
          >
            Logout
          </UButton>
          
          <UButton
            v-else
            variant="ghost"
            color="neutral"
            size="sm"
            to="/login"
          >
            Login
          </UButton>
        </div>
      </div>
    </div>
  </header>
</template>
