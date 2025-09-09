# AWS App Runner deployment for Nuxt + Supabase Todo App
# Usage: make deploy-docker-apprunner APP_NAME=my-app AWS_PROFILE=test

APP_NAME ?= nuxt-supabase-todo
AWS_PROFILE ?= test
REGION ?= us-east-1
ECR_REGISTRY ?= $(shell aws sts get-caller-identity --query Account --output text --profile $(AWS_PROFILE)).dkr.ecr.$(REGION).amazonaws.com
ECR_REPOSITORY ?= webapps
IMAGE_TAG ?= $(APP_NAME)
DOCKER_IMAGE ?= $(ECR_REGISTRY)/$(ECR_REPOSITORY):$(IMAGE_TAG)
SUPABASE_URL ?= https://euvlrvaylblltpwkaxec.supabase.co
SUPABASE_KEY ?= eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1dmxydmF5bGJsbHRwd2theGVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNTI0NjMsImV4cCI6MjA3MjkyODQ2M30.iyaWimCt0Cc19SaBpRK00Ph1vGP83FCH5TJqurBGriY

# ============================================
# ECR and Docker Operations
# ============================================

# Login to ECR
login-ecr:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_REGISTRY)

# Create shared webapps ECR repository
create-webapps-ecr:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws ecr create-repository --repository-name webapps --region $(REGION) || echo "Repository may already exist"

# Build Docker image with Supabase environment variables
build-docker:
	@echo "🐳 Building Docker image with Supabase configuration..."; \
	docker build \
		--build-arg SUPABASE_URL="$(SUPABASE_URL)" \
		--build-arg SUPABASE_KEY="$(SUPABASE_KEY)" \
		-t $(APP_NAME):latest \
		-t $(DOCKER_IMAGE) \
		.

# Push Docker image to ECR
push-docker: login-ecr create-webapps-ecr
	@export AWS_PROFILE=$(AWS_PROFILE); \
	echo "🚀 Pushing Docker image to ECR..."; \
	docker push $(DOCKER_IMAGE)

# ============================================
# App Runner Operations
# ============================================

# Create App Runner ECR access role
create-apprunner-access-role:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	echo "🔐 Creating App Runner ECR access role..."; \
	aws iam create-role \
		--role-name AppRunnerECRAccessRole \
		--assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"build.apprunner.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
		--region $(REGION) || echo "Role may already exist"; \
	aws iam attach-role-policy \
		--role-name AppRunnerECRAccessRole \
		--policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess \
		--region $(REGION) || echo "Policy may already be attached"

# Deploy using Docker image to App Runner
deploy-docker-apprunner: build-docker push-docker create-apprunner-access-role
	@export AWS_PROFILE=$(AWS_PROFILE); \
	ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text --profile $(AWS_PROFILE)); \
	echo "🚀 Deploying $(APP_NAME) to App Runner using Docker image..."; \
	aws apprunner create-service \
		--service-name "$(APP_NAME)" \
		--source-configuration '{"ImageRepository":{"ImageIdentifier":"$(DOCKER_IMAGE)","ImageConfiguration":{"Port":"3000","RuntimeEnvironmentVariables":{"NODE_ENV":"production","NITRO_PRESET":"node-server"}},"ImageRepositoryType":"ECR"},"AuthenticationConfiguration":{"AccessRoleArn":"arn:aws:iam::'$$ACCOUNT_ID':role/AppRunnerECRAccessRole"},"AutoDeploymentsEnabled":false}' \
		--instance-configuration '{"Cpu":"0.25 vCPU","Memory":"0.5 GB"}' \
		--region $(REGION) || echo "Service may already exist, updating instead"

# Delete App Runner service
delete-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner delete-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --profile $(AWS_PROFILE) --region $(REGION)) --region $(REGION) --profile $(AWS_PROFILE)

# Pause App Runner service
pause-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner pause-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --profile $(AWS_PROFILE) --region $(REGION)) --region $(REGION) --profile $(AWS_PROFILE)

# Resume App Runner service
resume-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner resume-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --profile $(AWS_PROFILE) --region $(REGION)) --region $(REGION) --profile $(AWS_PROFILE)

# Restart App Runner service (trigger new deployment)
restart-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner start-deployment --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --profile $(AWS_PROFILE) --region $(REGION)) --region $(REGION) --profile $(AWS_PROFILE)

# Check App Runner service status
status-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].[ServiceName,Status,ServiceUrl]' --output table --region $(REGION) --profile $(AWS_PROFILE)

# Get service URL
url-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner describe-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --profile $(AWS_PROFILE) --region $(REGION)) --region $(REGION) --profile $(AWS_PROFILE) --query 'Service.ServiceUrl' --output text

# View recent logs
logs-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	LOG_GROUP=$$(aws logs describe-log-groups --log-group-name-prefix "/aws/apprunner/$(APP_NAME)" --region $(REGION) --profile $(AWS_PROFILE) --query 'logGroups[0].logGroupName' --output text 2>/dev/null); \
	if [ "$$LOG_GROUP" != "None" ] && [ -n "$$LOG_GROUP" ]; then \
		aws logs tail $$LOG_GROUP --region $(REGION) --profile $(AWS_PROFILE) --since 1h; \
	else \
		echo "No logs found for service $(APP_NAME)"; \
	fi

# Open service in browser
open-apprunner:
	@URL=$$(make url-apprunner 2>/dev/null); \
	if [ -n "$$URL" ] && [ "$$URL" != "None" ]; then \
		echo "Opening https://$$URL"; \
		open "https://$$URL" 2>/dev/null || xdg-open "https://$$URL" 2>/dev/null || echo "Please open: https://$$URL"; \
	else \
		echo "Service not found or not ready"; \
	fi

# ============================================
# Local Development
# ============================================

# Local development
dev:
	npm run dev

# Build locally
build:
	npm run build

# Run linting
lint:
	npm run lint

# Test Docker image locally
test-docker: build-docker
	@echo "🧪 Testing Docker image locally on port 3001..."; \
	docker run --rm -p 3001:3000 $(APP_NAME):latest

# ============================================
# Help
# ============================================

help:
	@echo "Available commands:"
	@echo "  deploy-docker-apprunner  - Build and deploy using Docker to App Runner"
	@echo "  build-docker            - Build Docker image with Supabase config"
	@echo "  push-docker             - Push Docker image to ECR"
	@echo "  test-docker             - Test Docker image locally on port 3001"
	@echo "  status-apprunner        - Check App Runner service status"
	@echo "  logs-apprunner          - View App Runner service logs"
	@echo "  url-apprunner           - Get App Runner service URL"
	@echo "  open-apprunner          - Open App Runner service in browser"
	@echo "  pause-apprunner         - Pause App Runner service"
	@echo "  resume-apprunner        - Resume App Runner service"
	@echo "  restart-apprunner       - Restart App Runner service"
	@echo "  delete-apprunner        - Delete App Runner service"
	@echo "  dev                     - Start local development server"
	@echo "  build                   - Build locally"
	@echo "  lint                    - Run linting"