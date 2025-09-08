# AWS App Runner Deployment Guide

## Prerequisites
- AWS Account with App Runner access
- GitHub repository with your code
- Supabase project

## Deployment Steps

### 1. Push Code to GitHub
```bash
git add .
git commit -m "Prepare for AWS App Runner deployment"
git push origin main
```

### 2. Create App Runner Service
1. Go to AWS Console > App Runner
2. Click "Create service"
3. **Source**: GitHub
4. Connect to your repository
5. **Branch**: main
6. **Build settings**: Use configuration file (`apprunner.yaml`)

### 3. Configure Environment Variables
In the App Runner console, add these environment variables:

**Required:**
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Your Supabase anon key
- `NODE_ENV`: `production`
- `NITRO_PRESET`: `node-server`

### 4. Update Supabase Authentication Settings
1. Go to Supabase Dashboard > Authentication > URL Configuration
2. Add your App Runner URL to:
   - **Site URL**: `https://your-app-runner-url.region.awsapprunner.com`
   - **Redirect URLs**: 
     - `https://your-app-runner-url.region.awsapprunner.com/confirm`

### 5. Update GitHub OAuth App (if using)
1. Go to GitHub > Settings > Developer settings > OAuth Apps
2. Update your OAuth app:
   - **Homepage URL**: `https://your-app-runner-url.region.awsapprunner.com`
   - **Authorization callback URL**: `https://euvlrvaylblltpwkaxec.supabase.co/auth/v1/callback`

## Configuration Files Created

### `apprunner.yaml`
- Configures Node.js 18 runtime
- Installs dependencies and builds the app
- Runs the production server on port 3000

### `package.json` Updates
- Added `start` script for production server
- Points to `.output/server/index.mjs` (Nuxt 4 output)

### `nuxt.config.ts` Updates
- Production optimizations
- Security headers
- Nitro server preset configuration
- Runtime config for environment variables

## Deployment Process
1. App Runner pulls from your GitHub repository
2. Runs `npm ci --only=production` to install dependencies
3. Runs `npm run build` to build the Nuxt application
4. Starts the server with `npm start`
5. App is available on port 3000

## Environment Variables Reference
Copy your values from `.env` and set them in App Runner:

```
SUPABASE_URL=https://euvlrvaylblltpwkaxec.supabase.co
SUPABASE_KEY=your-supabase-anon-key
NODE_ENV=production
NITRO_PRESET=node-server
```

## Monitoring
- App Runner provides automatic logs and metrics
- Health checks are configured on port 3000
- Automatic scaling based on traffic

## Troubleshooting
- Check App Runner logs for build/runtime errors
- Verify environment variables are set correctly
- Ensure Supabase redirect URLs are updated
- Test authentication flows after deployment