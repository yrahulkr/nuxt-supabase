<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const toast = useToast()

const sign = ref<'in' | 'up'>('in')
const state = reactive({
  email: '',
  password: ''
})

watchEffect(() => {
  if (user.value) {
    return navigateTo('/')
  }
})

const fields = [{
  name: 'email',
  type: 'text' as const,
  label: 'Email',
  placeholder: 'Enter your email',
  required: true,
}, {
  name: 'password',
  label: 'Password',
  type: 'password' as const,
  placeholder: 'Enter your password',
}]

const runtimeConfig = useRuntimeConfig()

const providers = [{
  label: 'GitHub',
  icon: 'i-simple-icons-github',
  onClick: async () => {
    const { origin } = window.location
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'github',
      options: {
        redirectTo: `${origin}/confirm`,
      },
    })
    if (error) displayError(error)
  },
}]

const signIn = async (email, password) => {
  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  if (error) displayError(error)
}

const signUp = async (email, password) => {
  const { error } = await supabase.auth.signUp({
    email,
    password,
  })
  if (error) displayError(error)
  else {
    toast.add({
      title: 'Sign up successful',
      icon: 'i-lucide-check-circle',
      color: 'success',
    })
    await signIn(email, password)
  }
}

async function onSubmit() {
  const email = state.email
  const password = state.password

  if (sign.value === 'in') await signIn(email, password)
  else await signUp(email, password)
}

const displayError = (error) => {
  toast.add({
    title: 'Error',
    description: error.message,
    icon: 'i-lucide-alert-circle',
    color: 'error',
  })
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-emerald-50 to-slate-100 dark:from-emerald-950 dark:to-slate-900 flex items-center justify-center px-4 py-8">
    <div class="w-full max-w-md">
      <!-- Header -->
      <div class="text-center mb-8">
        <div class="flex justify-center mb-4">
          <div class="w-12 h-12 bg-emerald-500 rounded-full flex items-center justify-center">
            <UIcon name="i-lucide-user" class="w-6 h-6 text-white" />
          </div>
        </div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
          Welcome {{ sign === 'up' ? 'to our app' : 'back' }}
        </h1>
        <p class="text-gray-600 dark:text-gray-400">
          {{ sign === 'in' ? 'Sign in to your account' : 'Create your account to get started' }}
        </p>
      </div>

      <!-- Card -->
      <UCard class="shadow-xl border-0 bg-white/90 dark:bg-gray-900/90 backdrop-blur-sm">
        <div class="p-6">
          <UForm class="space-y-5" :state="state" @submit="onSubmit">
            <UFormGroup 
              v-for="field in fields" 
              :key="field.name" 
              :label="field.label" 
              :required="field.required"
              class="space-y-2"
            >
              <UInput 
                v-model="state[field.name]"
                :type="field.type" 
                :placeholder="field.placeholder"
                :required="field.required"
                size="lg"
                class="w-full"
                :ui="{ 
                  base: 'relative block w-full disabled:cursor-not-allowed disabled:opacity-75 focus:outline-none border-0',
                  rounded: 'rounded-lg',
                  placeholder: 'placeholder-gray-400 dark:placeholder-gray-500',
                  size: {
                    lg: 'px-4 py-3'
                  }
                }"
              />
            </UFormGroup>

            <UButton 
              type="submit" 
              block 
              size="lg" 
              class="w-full mt-6 bg-emerald-600 hover:bg-emerald-700 focus:ring-emerald-500"
            >
              {{ sign === 'in' ? 'Sign In' : 'Create Account' }}
            </UButton>
          </UForm>

          <UDivider label="or continue with" class="my-6" />

          <div class="space-y-3">
            <UButton
              v-for="provider in providers"
              :key="provider.label"
              :icon="provider.icon"
              variant="outline"
              block
              size="lg"
              class="border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800"
              @click="provider.onClick"
            >
              {{ provider.label }}
            </UButton>
          </div>

          <!-- Toggle Sign In/Up -->
          <div class="text-center mt-6 pt-4 border-t border-gray-200 dark:border-gray-700">
            <p class="text-sm text-gray-600 dark:text-gray-400">
              {{ sign === 'up' ? 'Already have an account?' : 'Don\'t have an account?' }}
              <UButton
                variant="link"
                class="p-0 text-emerald-600 hover:text-emerald-700 font-medium"
                @click="sign = sign === 'up' ? 'in' : 'up'"
              >
                {{ sign === 'in' ? 'Sign up' : 'Sign in' }}
              </UButton>
            </p>
          </div>
        </div>
      </UCard>

      <!-- Footer -->
      <div class="text-center mt-6 text-xs text-gray-500 dark:text-gray-400">
        Powered by <span class="font-medium">Nuxt</span> & <span class="font-medium">Supabase</span>
      </div>
    </div>
  </div>
</template>
