#!/bin/bash

# AWS App Runner Setup Script
set -e

echo "🚀 AWS App Runner Deployment Setup"
echo "=================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running from project root
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: Run this script from the project root directory${NC}"
    exit 1
fi

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI not found. Please install it:${NC}"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if AWS is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS CLI not configured. Please run:${NC}"
    echo "aws configure"
    exit 1
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git not found. Please install Git${NC}"
    exit 1
fi

# Check if it's a Git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo -e "${YELLOW}Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
    echo -e "${YELLOW}Please add a GitHub remote:${NC}"
    echo "git remote add origin https://github.com/username/repository.git"
    echo "git push -u origin main"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites met${NC}"

# Get configuration
echo ""
echo -e "${YELLOW}Configuration:${NC}"

# Get app name
read -p "App name (default: nuxt-supabase-todo): " APP_NAME
APP_NAME=${APP_NAME:-nuxt-supabase-todo}

# Get AWS region
read -p "AWS region (default: us-east-1): " REGION
REGION=${REGION:-us-east-1}

# Get GitHub repository
GITHUB_REPO=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*github.com[:/]\(.*\)\.git/\1/' || echo "")
if [ -z "$GITHUB_REPO" ]; then
    echo -e "${RED}Error: No GitHub remote found${NC}"
    echo "Please add a GitHub remote:"
    echo "git remote add origin https://github.com/username/repository.git"
    exit 1
fi

# Get current branch
BRANCH=$(git branch --show-current)

echo -e "App Name: ${GREEN}$APP_NAME${NC}"
echo -e "Region: ${GREEN}$REGION${NC}"
echo -e "Repository: ${GREEN}$GITHUB_REPO${NC}"
echo -e "Branch: ${GREEN}$BRANCH${NC}"

# Confirm
echo ""
read -p "Continue with deployment? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Create .env.production if it doesn't exist
if [ ! -f ".env.production" ]; then
    echo ""
    echo -e "${YELLOW}Creating .env.production template...${NC}"
    cp .env.example .env.production 2>/dev/null || {
        cat > .env.production << EOF
# Production Environment Variables
SUPABASE_URL=your-supabase-url
SUPABASE_KEY=your-supabase-anon-key
NODE_ENV=production
NITRO_PRESET=node-server
EOF
    }
    echo -e "${GREEN}✓ Created .env.production${NC}"
    echo -e "${YELLOW}Please edit .env.production with your actual values${NC}"
fi

# Export variables for make
export APP_NAME REGION GITHUB_REPO BRANCH

# Run deployment
echo ""
echo -e "${YELLOW}Starting deployment...${NC}"

# Use the Makefile
make full-deploy APP_NAME="$APP_NAME" REGION="$REGION" GITHUB_REPO="$GITHUB_REPO" BRANCH="$BRANCH"

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Set environment variables in AWS Console"
echo "2. Update Supabase redirect URLs"
echo "3. Test your deployed application"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "make status    - Check deployment status"
echo "make url       - Get application URL"
echo "make logs      - View application logs"
echo "make open      - Open app in browser"