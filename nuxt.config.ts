
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: process.env.NODE_ENV !== 'production' },

  modules: [
    '@nuxt/ui',
    '@nuxt/eslint',
    '@nuxtjs/supabase'
  ],

  pages: true,

  css: ['~/assets/css/main.css'],

  compatibilityDate: '2025-07-16',

  // Production optimizations
  nitro: {
    preset: process.env.NITRO_PRESET || 'node-server',
    // Enable compression for better performance
    compressPublicAssets: true,
  },

  // Runtime config for environment variables
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseAnonKey: process.env.SUPABASE_KEY,
    }
  },

  // Production build optimizations
  build: {
    transpile: process.env.NODE_ENV === 'production' ? ['@nuxt/ui'] : []
  },

  // SSR configuration
  ssr: true,

  // Security headers for production
  routeRules: {
    '/**': {
      headers: process.env.NODE_ENV === 'production' ? {
        'X-Frame-Options': 'DENY',
        'X-Content-Type-Options': 'nosniff',
        'Referrer-Policy': 'strict-origin-when-cross-origin'
      } : {}
    }
  }
})