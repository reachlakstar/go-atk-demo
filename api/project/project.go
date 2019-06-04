package main

import (
	"github.com/lakstap/go-atk"
	"github.com/micro/go-log"
	api "github.com/lakstap/go-atk-demo/api/project/proto"
	"github.com/lakstap/go-atk-demo/api/project/handler"
)

func main() {

	/*
	 * create the ATK API Service using the ATK Api
	 * runs on localhost port 9090
	 */

	apiService := atk.NewATKGrpcService(atk.ATKGrpcServiceOption{
		ServiceName: "go.micro.srv.atk.api.project",
		Version:     "latest",
	})

	// Register Handler
	api.RegisterATKProjectHandler(apiService.Service.Server(), &handler.ATKProject{
		ATKGrpcService: *apiService,
	})

	// Run service
	if err := apiService.RunATKGrpcService(); err != nil {
		log.Fatal(err)
	}
}
