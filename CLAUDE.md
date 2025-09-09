# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Development:**
- `npm run dev` - Start development server on http://localhost:3000
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run generate` - Generate static site

**Code Quality:**
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint issues automatically

## Architecture

This is a **Nuxt 4 + Supabase** todo list application built with:
- **Frontend**: Nuxt 4 with TypeScript, @nuxt/ui components
- **Backend**: Supabase (PostgreSQL database, authentication, real-time)
- **Styling**: @nuxt/ui with Tailwind CSS (emerald primary, slate neutral colors)

### Key Directories

- `app/` - Main application code (Nuxt 4 uses app directory structure)
  - `pages/` - File-based routing (index, login, confirm pages)
  - `components/` - Vue components (AppHeader, etc.)
  - `layouts/` - Application layouts
  - `server/api/` - Server-side API routes 
  - `types/` - TypeScript type definitions
  - `assets/css/` - Global CSS files

### Database Schema

The app uses a single Supabase table `tasks`:
- `id` (number, primary key)
- `title` (string, nullable)
- `completed` (boolean, nullable) 
- `user` (string, nullable, foreign key to auth.users)
- `created_at` (string, timestamp)

Generated types are in `app/types/database.types.ts` - these should be regenerated when database schema changes.

### Authentication Flow

- Uses `@nuxtjs/supabase` module for auth integration
- Server-side auth utilities: `serverSupabaseUser()`, `serverSupabaseClient()`
- Client-side composables: `useSupabaseUser()`, `useSupabaseClient()`
- Auth pages: `/login`, `/confirm` (for email confirmation)

### State Management

No external state management library - uses:
- `useAsyncData()` for server-side data fetching with caching
- `ref()` for local component state
- Direct Supabase client calls for CRUD operations
- Real-time updates handled via optimistic UI updates

### API Routes

Server API routes in `app/server/api/`:
- `/api/tasks` - Demonstrates server-side data fetching with user authentication
- Uses `serverSupabaseClient<Database>()` for type-safe database queries

### UI Framework

Uses **@nuxt/ui** components (free version):
- `UContainer`, `UInput`, `UButton`, `UCard`, `USwitch`, `UModal`, `UForm`, `UFormGroup`, `UBadge`, etc.
- Custom theme config in `app/app.config.ts`
- Primary color: emerald, Neutral: slate
- Note: This project uses the free @nuxt/ui, not the subscription-based @nuxt/ui-pro
- Deployment