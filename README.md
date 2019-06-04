# go-atk-demo

This is the GO ATK Demo API Project built using Go-API Tool Kit

![ATK Architecture](Arch.png)

# Prereqs

Service discovery is used for name resolution, routing and centralising metadata.

```
# install consul
brew install consul

# run consul in your local environment
export MICRO_REGISTRY=consul
source ~/.profile
consul agent -dev
```

# Protobuf
Protobuf is used for code generation. It reduces the amount of boilerplate code needed to be written.

```
- make sure you have installed xcode command line tools
brew install protobuf

```

## Getting Started

Here we’ll quickly generate an sample Project using go-ATK
```
# Make sure you have GO path and Path set in the profile
export GOPATH=/Users/{Id}/go
export PATH=$PATH:$GOPATH/bin

# Get the ATK Project
go get -u github.com/lakstap/go-atk-demo

# Install additional dependencies
go get -d github.com/envoyproxy/protoc-gen-validate
# go to ~go/src/github.com/envoyproxy/protoc-gen-validate and run
make build

# Build ( run from ~/go/src/github.com/lakstap/go-atk-demo/ )
. pre-build.sh
make build-all

# setup the secrets ( mostly running on container )

```

## Sample gateway
```
# build the gateway
make proto build-gateway

# run the gateway
make run-gwy # change the end point in the Makefile

# Test methods
Test using swagger UI
http://localhost:8090/swagger

```


## GoLand IDE Issues
```
    go get -u k8s.io/client-go
    go get -u k8s.io/api
    go get -u k8s.io/apimachinery
```
## Sample API
```
# run the API
make run-api-project # change the end point in the Makefile

```
