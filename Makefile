# AWS App Runner deployment for Nuxt + Supabase Todo App
# Usage: make deploy-todo-apprunner APP_NAME=my-app AWS_PROFILE=test

APP_NAME ?= nuxt-supabase-todo
AWS_PROFILE ?= test
REGION ?= us-east-1
GITHUB_REPO ?= $(shell git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
BRANCH ?= main

# Ensure changes are committed and pushed
commit-changes:
	@if [ -n "$$(git status --porcelain)" ]; then \
		git add .; \
		git commit -m "Deploy: AWS App Runner configuration" || echo "Nothing to commit"; \
		git push origin $(BRANCH); \
		echo "✓ Changes pushed to GitHub"; \
	else \
		echo "✓ No changes to commit"; \
	fi

# Deploy Nuxt app to App Runner
deploy-todo-apprunner: commit-changes
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner create-service \
		--service-name "$(APP_NAME)" \
		--source-configuration '{"ImageRepository":null,"CodeRepository":{"RepositoryUrl":"https://github.com/$(GITHUB_REPO)","SourceCodeVersion":{"Type":"BRANCH","Value":"$(BRANCH)"},"CodeConfiguration":{"ConfigurationSource":"CONFIGURATION_FILE"}},"AutoDeploymentsEnabled":true}' \
		--instance-configuration '{"Cpu":"0.25 vCPU","Memory":"0.5 GB"}' \
		--region $(REGION) || echo "Service may already exist, updating instead"; \
	aws apprunner start-deployment --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION) 2>/dev/null || echo "Deployment will start automatically"

# Delete App Runner service
delete-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner delete-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION)

# Pause App Runner service
pause-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner pause-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION)

# Resume App Runner service
resume-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner resume-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION)

# Restart App Runner service (trigger new deployment)
restart-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner start-deployment --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION)

# Check App Runner service status
status-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].[ServiceName,Status,ServiceUrl]' --output table --region $(REGION)

# Get service URL
url-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	aws apprunner describe-service --service-arn $$(aws apprunner list-services --query 'ServiceSummaryList[?ServiceName==`$(APP_NAME)`].ServiceArn' --output text --region $(REGION)) --region $(REGION) --query 'Service.ServiceUrl' --output text

# View recent logs
logs-todo-apprunner:
	@export AWS_PROFILE=$(AWS_PROFILE); \
	LOG_GROUP=$$(aws logs describe-log-groups --log-group-name-prefix "/aws/apprunner/$(APP_NAME)" --region $(REGION) --query 'logGroups[0].logGroupName' --output text 2>/dev/null); \
	if [ "$$LOG_GROUP" != "None" ] && [ -n "$$LOG_GROUP" ]; then \
		aws logs tail $$LOG_GROUP --region $(REGION) --since 1h; \
	else \
		echo "No logs found for service $(APP_NAME)"; \
	fi

# Open service in browser
open-todo-apprunner:
	@URL=$$(make url-todo-apprunner 2>/dev/null); \
	if [ -n "$$URL" ] && [ "$$URL" != "None" ]; then \
		echo "Opening https://$$URL"; \
		open "https://$$URL" 2>/dev/null || xdg-open "https://$$URL" 2>/dev/null || echo "Please open: https://$$URL"; \
	else \
		echo "Service not found or not ready"; \
	fi

# Local development
dev:
	npm run dev

# Build locally
build:
	npm run build

# Run linting
lint:
	npm run lint