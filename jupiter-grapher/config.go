package main

import (
	"fmt"
	"github.com/jessevdk/go-flags"
	"os"
)

type Options struct {
	Version           bool   `short:"v" long:"version" description:"Print version info."`
	StartTime string `short:"t" long:"start-time" description:"Start time (in RFC 3339 format) to calculate metric timestamps. Defaults to now, which might not be what you want."`
	Resolution int `short:"r" long:"resolution" description:"Number of milliseconds to sample for each metric. (default: 500)"`
	File string `short:"F" long:"file" description:"Path to WAV file with Jupiter noise data."`
	Addr string `short:"A" long:"addr" description:"Timeseries DB address."`
}

const Version string = "0.0.1"

func parseConfig() (*Options, error) {
	var opts = &Options{}
	_, err := flags.Parse(opts)
	if err != nil {
		if err.(*flags.Error).Type == flags.ErrHelp {
			os.Exit(0)
		}
		return nil, err
	}
	if opts.Version {
		fmt.Printf("jupiter-grapher version %s\n", Version)
		os.Exit(0)
	}
	return opts, nil
}
