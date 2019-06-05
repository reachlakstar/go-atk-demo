package handler

import (
	"golang.org/x/net/context"
	"github.com/micro/go-log"
	project "github.com/lakstap/go-atk-demo/api/project/proto"
	"github.com/lakstap/go-atk"
)
type ATKProject struct {
	ATKGrpcService atk.ATKGrpcService
}
type ctxKey struct{}

// Project.Search is called by the API as /project/search with POST  {"name": "foo"}
func (e *ATKProject) GetHelloWorld(ctx context.Context, req *project.HelloWorldRequest, rsp *project.HelloWorldResponse) error {
	log.Log("GetProject: Received GRPC Request from the Client")

	/* userId, err := tool.GetUIDFromContext(ctx)

	if err != nil {
		return errors.BadRequest("go.micro.srv.atk.api.project", "GetProject: Authentication failed because no user id provided")
	}
*/
	if err := req.Validate(); err != nil {
		return err
	}

	log.Log("GetProject: Received GRPC Request -> invoking client service")
	
	rsp.Message = "Welcome!"  + "," + req.Message
	return nil
}
