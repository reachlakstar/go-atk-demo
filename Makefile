# import deploy config
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))


.PHONY: help proto build

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

proto:
	for d in gateway api srv; do \
		for f in $$d/**/proto/*.proto; do \
		    protof=`basename $$f`; \
            protod=`dirname $$f`; \
		    if test $$d = "gateway"; then \
                protoc -I/usr/local/include -I. \
                  -I${GOPATH}/src \
                  -I=${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway \
                  -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
                  -I${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate \
                  --go_out=plugins=grpc:. $$f; \
                protoc -I/usr/local/include -I. \
                  -I${GOPATH}/src \
                  -I=${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway \
                  -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
                  -I${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate \
                  --grpc-gateway_out=logtostderr=true:. $$f; \
                protoc -I/usr/local/include -I. \
                  -I${GOPATH}/src \
                  -I=${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway \
                  -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
                  -I${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate \
                  --swagger_out=logtostderr=true:. $$f; \
                protoc -I/usr/local/include -I. \
                  -I${GOPATH}/src \
                  -I=${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway \
                  -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
                  -I${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate \
                  --validate_out=lang=go:. $$f; \
            elif test $$d = "api"; then \
                protoc --proto_path=${GOPATH}/src:. --go_out=. --micro_out=. $$f; \
                cd ${CWD}/$$protod; \
                protoc -I/usr/local/include -I. -I${GOPATH}/src --gotag_out=xxx="graphql+\"-\" bson+\"-\"":. $$protof; \
                cd ${CWD}; \
                protoc -I/usr/local/include -I. \
                          -I${GOPATH}/src \
                          -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
                          -I${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate \
                          --validate_out=lang=go:. $$f; \
            fi \
		done \
	done \


up-gwy: build-gateway run-gwy ## Run the gateway

# DOCKER TASKS
# Build the container
build-all: proto merge-swag build-gateway build-api-project
build-gateway: ## Build the Docker Image for gateway
	docker build -f .deploy/gateway/Dockerfile -t ${GW_NAME} .

build-api-project: ## Build the Docker Image for API Project
	docker build -f .deploy/api/project/Dockerfile -t ${API_PROJECT_NAME} .

# Docker publish
publish-all: publish-gwy publish-api-project
publish-gwy: publish-gwy-version publish-gwy-latest

publish-gwy-latest: ## Publish the `latest` taged container to docker hub
	@echo 'publish latest gateway to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GW_NAME):latest

publish-gwy-version: ## Publish the `{version}` taged container to  docker hub
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GW_NAME):$(VERSION)

# publish api
publish-api-project: publish-api-project-version publish-api-project-latest

publish-api-project-latest: ## Publish the `latest` taged container to  docker hub
	@echo 'publish latest API to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(API_PROJECT_NAME):latest

publish-api-project-version: ## Publish the `{version}` taged container to  docker hub
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(API_PROJECT_NAME):$(VERSION)

# Docker tagging
tag-all: tag-gwy tag-api-project
tag-gwy: tag-gwy-version tag-gwy-latest  ## Generate container tags for the `{version}` ans `latest` tags

tag-gwy-latest: ## Generate container `{version}` tag
	docker tag $(DOCKER_REPO)/$(GW_NAME):$(VERSION) $(DOCKER_REPO)/$(GW_NAME):latest

tag-gwy-version: ## Generate container `latest` tag
	@echo 'create tag gateway $(VERSION)'
	docker tag $(GW_NAME) $(DOCKER_REPO)/$(GW_NAME):$(VERSION)

# Tag API
tag-api-project: tag-api-project-version tag-api-project-latest  ## Generate container tags for the `{version}` ans `latest` tags

tag-api-project-latest: ## Generate container `{version}` tag
	@echo 'create tag API latest'
	docker tag $(DOCKER_REPO)/$(API_PROJECT_NAME):$(VERSION) $(DOCKER_REPO)/$(API_PROJECT_NAME):latest

tag-api-project-version: ## Generate container `latest` tag
	@echo 'create tag API $(VERSION)'
	docker tag $(API_PROJECT_NAME) $(DOCKER_REPO)/$(API_PROJECT_NAME):$(VERSION)


# swagger merge
merge-swag: ## Generate single swagger file
	# swagger mixin gateway/api/proto/gwy-project.swagger.json  -o ./gateway/api/proto/swagger.json
	mv ./gateway/api/proto/gwy-project.swagger.json ./gateway/api/proto/swagger.json

# Docker run
run-gwy: ## Run Gateway Replace the end point
	docker run -it --rm --env-file=./deploy.env -p=8090:8090 $(GW_NAME) --endpoint=0.0.0.0:9090 --swagger_dir=/go/gateway/api/proto/

run-api-project: ## Run API
	docker run -it --rm --env-file=./deploy.env -p=9090:9090 $(API_PROJECT_NAME)  --server_address=0.0.0.0:9090


# login to docker..com
## publish the `{VERSION}` and `latest` tagged containers to  docker hub
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	docker login docker.com  ## docker : you_shoud_know_password

version: ## Output the current version
	@echo $(VERSION)
