# AWS App Runner Deployment Guide

## Prerequisites
- AWS Account with App Runner access
- Docker installed locally
- AWS ECR repository access
- Supabase project
- AWS CLI configured with appropriate profile

## 🐳 Docker-based Deployment

### Quick Start
```bash
# Deploy with defaults (uses test profile, us-east-1 region)
make deploy-docker-apprunner

# Custom deployment
make deploy-docker-apprunner APP_NAME=my-todo-app AWS_PROFILE=production REGION=us-west-2
```

This single command will:
1. **Build** Docker image with Supabase environment variables baked in
2. **Create** ECR repository if it doesn't exist
3. **Push** image to ECR
4. **Create** App Runner ECR access role
5. **Deploy** to App Runner

### 📊 Management Commands
```bash
# Check deployment status
make status-apprunner

# Get your app URL
make url-apprunner

# View application logs
make logs-apprunner

# Open app in browser
make open-apprunner

# Restart deployment (after code changes)
make restart-apprunner

# Pause service (saves costs)
make pause-apprunner

# Resume service
make resume-apprunner

# Delete service
make delete-apprunner
```

### 🐳 Docker Commands
```bash
# Build Docker image locally
make build-docker

# Push Docker image to ECR
make push-docker

# Test Docker image locally (port 3001)
make test-docker
```

### 🛠️ Development Commands
```bash
# Local development
make dev

# Build locally
make build

# Run linting
make lint

# Show all available commands
make help
```

## Configuration

### Default Settings
The Makefile includes these defaults (can be overridden):

- **APP_NAME**: `nuxt-supabase-todo`
- **AWS_PROFILE**: `test` 
- **REGION**: `us-east-1`
- **SUPABASE_URL**: `https://euvlrvaylblltpwkaxec.supabase.co`
- **SUPABASE_KEY**: Your Supabase anon key (included in Makefile)

### Docker Image Build
The Docker image is built with:
- **Supabase environment variables** baked in at build time
- **Node.js 22 Alpine** base image
- **Production optimizations** (dependency pruning, compression)
- **Port 3000** exposed for the Nuxt server

### App Runner Configuration
- **Instance**: 0.25 vCPU, 0.5 GB RAM (cost-optimized)
- **Runtime Environment**: 
  - `NODE_ENV=production`
  - `NITRO_PRESET=node-server`
- **Auto-deployment**: Disabled (manual deployments via Docker)

## Deployment Process

1. **Build Phase**: Docker builds the Nuxt app with Supabase config
2. **Push Phase**: Image is tagged and pushed to ECR
3. **Deploy Phase**: App Runner creates service from ECR image
4. **Ready**: App available at the App Runner URL

## Supabase Configuration

### Authentication Setup
After deployment:
1. Get your App Runner URL: `make url-apprunner`
2. Go to Supabase Dashboard > Authentication > URL Configuration
3. Add your App Runner URL to:
   - **Site URL**: `https://your-app-runner-url.region.awsapprunner.com`
   - **Redirect URLs**: 
     - `https://your-app-runner-url.region.awsapprunner.com/confirm`

### Environment Variables
The following are **built into the Docker image**:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Your Supabase anon key

App Runner runtime environment includes:
- `NODE_ENV=production`
- `NITRO_PRESET=node-server`

## Cost Optimization
- **Pause service** when not in use: `make pause-apprunner`
- **Resume service** when needed: `make resume-apprunner`
- **Smallest instance** size configured (0.25 vCPU / 0.5 GB)
- **Manual deployments** only (no auto-deployment costs)

## Monitoring & Debugging
- **Status**: `make status-apprunner`
- **Logs**: `make logs-apprunner` 
- **Local testing**: `make test-docker` (runs on port 3001)
- **AWS Console**: App Runner service dashboard

## Troubleshooting

### Build Issues
```bash
# Test Docker build locally
make build-docker

# Test image locally
make test-docker
```

### Deployment Issues
```bash
# Check service status
make status-apprunner

# View logs
make logs-apprunner

# Restart service
make restart-apprunner
```

### Access Issues
- Verify AWS profile has ECR and App Runner permissions
- Check that IAM role `AppRunnerECRAccessRole` was created
- Ensure ECR repository exists in the correct region

### Supabase Issues
- Verify Supabase URL and key in Makefile are correct
- Update Supabase auth redirect URLs after deployment
- Check that environment variables are properly set in the Docker image

## Advanced Usage

### Custom Supabase Config
If you need different Supabase settings, update the Makefile variables:
```bash
make deploy-docker-apprunner \
  SUPABASE_URL=https://your-project.supabase.co \
  SUPABASE_KEY=your-anon-key
```

### Multiple Environments
Deploy to different environments:
```bash
# Production
make deploy-docker-apprunner \
  APP_NAME=todo-prod \
  AWS_PROFILE=production \
  REGION=us-west-2

# Staging  
make deploy-docker-apprunner \
  APP_NAME=todo-staging \
  AWS_PROFILE=staging \
  REGION=us-east-1
```