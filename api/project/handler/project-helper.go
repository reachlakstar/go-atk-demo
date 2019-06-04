package handler

import (
	"time"
	"github.com/golang/protobuf/ptypes"
	"github.com/micro/go-log"
)

func GetTimestamp() (string, error) {
	// Create protobuf Timestamp value from golang Time
	t := time.Now().UTC()
	ts, err := ptypes.TimestampProto(t)
	_tstr := ptypes.TimestampString(ts)

	if err != nil {
		log.Fatalf("failed to convert golang Time to protobuf Timestamp: %#v", err)
	}
	return _tstr, nil
}
