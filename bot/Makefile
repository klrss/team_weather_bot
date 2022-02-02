TAG ?= latest
REGISTRY_ID ?= 367668710117
REPOSITORY_REGION ?= eu-central-1
APP_NAME ?= bot
ENV_NAME ?= dev

APP_TOKEN ?= error
APP_WEATHER_KEY ?= error
REPO_NAME = $(REGISTRY_ID).dkr.ecr.$(REPOSITORY_REGION).amazonaws.com/${APP_NAME}-${ENV_NAME}

.PHONY: build
build:
	aws ecr get-login-password --region $(REPOSITORY_REGION) | docker login --username AWS --password-stdin $(REGISTRY_ID).dkr.ecr.$(REPOSITORY_REGION).amazonaws.com
	
	docker build --build-arg app_token=$(APP_TOKEN) --build-arg app_weather_key=$(APP_WEATHER_KEY) -t $(REPO_NAME):$(TAG) -f ./Dockerfile .
	
	docker push $(REPO_NAME):$(TAG)
