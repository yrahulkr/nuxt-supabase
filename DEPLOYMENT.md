# AWS App Runner Deployment Guide

## Prerequisites
- AWS Account with App Runner access
- GitHub repository (can be private)
- Supabase project
- AWS CLI configured with appropriate profile

## Quick Deployment with Makefile

### 🚀 Deploy Your App
```bash
# Simple deployment (uses defaults)
make deploy-todo-apprunner

# Custom deployment with AWS profile
make deploy-todo-apprunner APP_NAME=my-todo-app AWS_PROFILE=test REGION=us-west-2
```

### 📊 Management Commands
```bash
# Check deployment status
make status-todo-apprunner

# Get your app URL
make url-todo-apprunner

# View application logs
make logs-todo-apprunner

# Open app in browser
make open-todo-apprunner

# Restart deployment (after code changes)
make restart-todo-apprunner

# Pause service (saves costs)
make pause-todo-apprunner

# Resume service
make resume-todo-apprunner

# Delete service
make delete-todo-apprunner
```

### 🛠️ Development Commands
```bash
# Local development
make dev

# Build locally
make build

# Run linting
make lint
```

## Manual Deployment Steps (Alternative)

### 1. GitHub Repository Setup
- Repository can be **private** or public
- For private repos, you'll need to connect GitHub App on first deployment
- Automatic deployments are enabled by default

### 2. Deploy with Makefile
The Makefile automatically:
- Commits and pushes any pending changes
- Creates the App Runner service
- Configures automatic deployments from your Git branch

### 3. Configure Environment Variables
**After deployment**, add these in AWS Console > App Runner > Your Service > Configuration:

**Required:**
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Your Supabase anon key  
- `NODE_ENV`: `production`
- `NITRO_PRESET`: `node-server`

### 4. Update Supabase Authentication Settings
1. Get your App Runner URL: `make url-todo-apprunner`
2. Go to Supabase Dashboard > Authentication > URL Configuration
3. Add your App Runner URL to:
   - **Site URL**: `https://your-app-runner-url.region.awsapprunner.com`
   - **Redirect URLs**: 
     - `https://your-app-runner-url.region.awsapprunner.com/confirm`

## Configuration Files

### `apprunner.yaml`
- Configures **Node.js 20** runtime (matches your local environment)
- Installs production dependencies only
- Builds the Nuxt application
- Runs production server on port 3000
- Instance size: 0.25 vCPU / 0.5 GB (cost-optimized)

### `Makefile` 
- **Variables**: APP_NAME, AWS_PROFILE, REGION, GITHUB_REPO, BRANCH
- **Auto-commit**: Commits and pushes changes before deployment
- **Error handling**: Gracefully handles existing services
- **GitHub integration**: Works with private repositories

### `package.json` Updates
- Added `start` script: `node .output/server/index.mjs`
- Points to Nuxt 4 server output

### `nuxt.config.ts` Updates
- Production optimizations (devtools disabled in production)
- Security headers for production
- Nitro server preset configuration
- Runtime config for environment variables
- Asset compression enabled

## Deployment Process
1. **Makefile commits** any pending changes and pushes to GitHub
2. **App Runner pulls** from your GitHub repository (private repos supported)
3. **Build phase**: Runs `npm ci --only=production` and `npm run build`
4. **Run phase**: Starts server with `npm start` on port 3000
5. **Auto-scaling**: Handles traffic automatically
6. **Auto-deployment**: New commits trigger automatic redeployments

## Default Configuration
- **App Name**: `nuxt-supabase-todo`
- **AWS Profile**: `default` 
- **Region**: `us-east-1`
- **Branch**: `main`
- **Instance**: 0.25 vCPU, 0.5 GB RAM
- **Runtime**: Node.js 20

## Environment Variables Reference
Set these in AWS App Runner console after deployment:

```bash
SUPABASE_URL=https://euvlrvaylblltpwkaxec.supabase.co
SUPABASE_KEY=your-supabase-anon-key
NODE_ENV=production
NITRO_PRESET=node-server
```

## Private Repository Setup
1. **First deployment**: Use AWS Console to connect GitHub App
2. **Grant access** to your private repository
3. **Subsequent deployments**: Use Makefile commands normally

## Cost Optimization
- **Pause service** when not in use: `make pause-todo-apprunner`
- **Resume service** when needed: `make resume-todo-apprunner`
- **Smallest instance** size configured (0.25 vCPU / 0.5 GB)
- **Auto-scaling** only when traffic increases

## Monitoring & Debugging
- **Status**: `make status-todo-apprunner`
- **Logs**: `make logs-todo-apprunner` 
- **AWS Console**: App Runner service dashboard
- **Health checks**: Automatic on port 3000

## Troubleshooting
- **Build failures**: Check `make logs-todo-apprunner` for errors
- **Environment variables**: Verify they're set in AWS Console
- **Supabase auth**: Update redirect URLs after deployment
- **Private repo**: Ensure GitHub App has repository access
- **Region issues**: Specify correct region with `REGION=us-west-2`