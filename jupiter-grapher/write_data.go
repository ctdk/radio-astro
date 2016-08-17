package main

import (
	"fmt"
	"net"
	"strings"
)

type metricWriter interface {
	write(map[string]string, int64, float64) error
	send() error
	close() error
}

type openTSDBwriter struct {
	conn net.Conn
	series string
	batch bool
}

func newOpenTSDB(address string, series string, batch bool) (*openTSDBwriter, error) {
	conn, err := net.Dial("tcp", address)
	if err != nil {
		return nil, err
	}
	return &openTSDBwriter{ conn: conn, series: series, batch: batch, }, nil
}

// batch later?

func (o *openTSDBwriter) write(tags map[string]string, timestamp int64, val float64) error {
	tagArr := make([]string, 0, len(tags))
	for k, v := range tags {
		tagArr = append(tagArr, fmt.Sprintf("%s=%s", k, v))
	}
	tagStr := strings.Join(tagArr, " ")
	metric := fmt.Sprintf("put %s %d %.10f %s\n", o.series, timestamp, val, tagStr)
	_, err := o.conn.Write([]byte(metric))
	if err != nil {
		return err
	}
	return nil
}
