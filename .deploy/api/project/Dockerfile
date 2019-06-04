# Accept the Go version for the image to be set as a build argument.
# Default to Go 1.11
ARG GO_VERSION=1.11

# First stage: build the executable.
FROM golang:${GO_VERSION}-alpine AS builder

# Create the user and group files that will be used in the running container to
# run the process as an unprivileged user.
RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group

# Install the Certificate-Authority certificates for the atk-api to be able to make
# calls to HTTPS endpoints.
# Git is required for fetching the dependencies.
RUN apk add --no-cache ca-certificates git

# Set the environment variables for the go command:
# * CGO_ENABLED=0 to build a statically-linked executable
# * GOFLAGS=-mod=vendor to force `go build` to look into the `/vendor` folder.
#ENV CGO_ENABLED=0 GOFLAGS=-mod=vendor
ENV CGO_ENABLED=0

# Set the working directory outside $GOPATH to enable the support for modules.
WORKDIR /src

# Fetch dependencies first; they are less susceptible to change on every build
# and will therefore be cached for speeding up the next build
COPY ./go.mod ./go.sum ./
# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

# COPY the source code as the last step
COPY api/project ./
COPY api/project/handler ./api/project/handler
COPY api/project/proto ./api/project/proto

# Build the executable to `/atk`. Mark the build as statically linked.
#RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o cmd/great1/great1.go
#RUN GOOS=darwin GOARCH=amd64 go build -v -o /bin/great1 cmd/great1/great1.go
RUN go build \
    -installsuffix 'static' \
    -o /go-atk-api-demo-prj .

# Final stage: the running container.
#FROM scratch AS final
FROM golang:alpine AS final

# Import the user and group files from the first stage.
COPY --from=builder /user/group /user/passwd /etc/

# Import the Certificate-Authority certificates for enabling HTTPS.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the compiled executable from the second stage.
COPY --from=builder /go-atk-api-demo-prj /go-atk-api-demo-prj

# Declare the port on which the gateway will be exposed.
# As we're going to run the executable as an unprivileged user, we can't bind
# to ports below 1024.
EXPOSE 9090

# Perform any further action as an unprivileged user.
USER nobody:nobody

# Metadata params
ARG VERSION=0.0.1
ARG BUILD_DATE
ARG VCS_URL=go-atk-demo
ARG VCS_REF=1
ARG NAME=go-atk-api-demo-prj
ARG VENDOR=atk

# Metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.description="Example of multi-stage docker build" \
      org.label-schema.url="https://github.com" \
      org.label-schema.vcs-url=https://github.com/lakstap/$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor=$VENDOR \
      org.label-schema.version=$VERSION \
      org.label-schema.docker.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -it -p 9090:9090  go-atk-api-demo-prj"

# Run the compiled binary.
ENTRYPOINT ["/go-atk-api-demo-prj"]