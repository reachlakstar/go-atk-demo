// Code generated by protoc-gen-micro. DO NOT EDIT.
// source: api/project/proto/api-project.proto

package go_micro_srv_atk_api_project

import (
	fmt "fmt"
	proto "github.com/golang/protobuf/proto"
	math "math"
)

import (
	context "context"
	client "github.com/micro/go-micro/client"
	server "github.com/micro/go-micro/server"
)

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion3 // please upgrade the proto package

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ client.Option
var _ server.Option

// Client API for ATKProject service

type ATKProjectService interface {
	GetHelloWorld(ctx context.Context, in *HelloWorldRequest, opts ...client.CallOption) (*HelloWorldResponse, error)
}

type aTKProjectService struct {
	c    client.Client
	name string
}

func NewATKProjectService(name string, c client.Client) ATKProjectService {
	if c == nil {
		c = client.NewClient()
	}
	if len(name) == 0 {
		name = "go.micro.srv.atk.api.project"
	}
	return &aTKProjectService{
		c:    c,
		name: name,
	}
}

func (c *aTKProjectService) GetHelloWorld(ctx context.Context, in *HelloWorldRequest, opts ...client.CallOption) (*HelloWorldResponse, error) {
	req := c.c.NewRequest(c.name, "ATKProject.GetHelloWorld", in)
	out := new(HelloWorldResponse)
	err := c.c.Call(ctx, req, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Server API for ATKProject service

type ATKProjectHandler interface {
	GetHelloWorld(context.Context, *HelloWorldRequest, *HelloWorldResponse) error
}

func RegisterATKProjectHandler(s server.Server, hdlr ATKProjectHandler, opts ...server.HandlerOption) error {
	type aTKProject interface {
		GetHelloWorld(ctx context.Context, in *HelloWorldRequest, out *HelloWorldResponse) error
	}
	type ATKProject struct {
		aTKProject
	}
	h := &aTKProjectHandler{hdlr}
	return s.Handle(s.NewHandler(&ATKProject{h}, opts...))
}

type aTKProjectHandler struct {
	ATKProjectHandler
}

func (h *aTKProjectHandler) GetHelloWorld(ctx context.Context, in *HelloWorldRequest, out *HelloWorldResponse) error {
	return h.ATKProjectHandler.GetHelloWorld(ctx, in, out)
}
