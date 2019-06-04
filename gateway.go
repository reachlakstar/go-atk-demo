// package main starts the ATK Gateway for the OSFI K8S API
// this gateway reads protobuf service definitions and generates
// a reverse-proxy server which translates a RESTful JSON API into gRPC.
package main

import (
	"flag"
	"context"
	"github.com/golang/glog"
	"github.com/lakstap/go-atk"
	"github.com/micro/go-log"
	api "github.com/lakstap/go-atk-demo/gateway/api/proto"
	"fmt"
	"strings"
)
// Url Path parameters
var urlPath = []string{"project"}
func main() {
	flag.Parse()
	flag.Set("logtostderr", "true")

	defer glog.Flush()
	/*
	 * Create the context background
	 */
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	urlString := strings.Join(urlPath, ":")
	/*
	 * create the ATK Gateway using the ATK Api
	 * runs on localhost port 8080
	 */
	fmt.Println("Gateway:: Getting Started with multiple end points...")
	gateway := atk.NewATKGateway(
		atk.WithEndpointHandlerOption(api.RegisterATKProjectHandlerFromEndpoint))

	// Run service
	if err := gateway.RunGateway(ctx,false,urlString,false); err != nil {
		log.Fatal(err)
	}
}
