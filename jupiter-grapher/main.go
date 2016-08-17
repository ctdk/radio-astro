package main

import (
	"azul3d.org/engine/audio"
	_ "azul3d.org/engine/audio/wav"
	"fmt"
	"os"
	"log"
	"math"
	"time"
)

func main() {
	opts, err := parseConfig()
	if err != nil {
		log.Fatal(err)
	}

	var oTime time.Time
	if opts.StartTime != "" {
		z, terr := time.Parse(time.RFC3339, opts.StartTime)
		if terr != nil {
			log.Fatal("2 ", terr)
		}
		oTime = z.UTC()
	}

	// Later recording directly from the radio will be an option. For now,
	// analyze a WAV file.
	f, err := os.Open(opts.File)
	if err != nil {
		log.Fatal("3 ", err)
	}
	defer f.Close()

	// Configure InfluxDB.
	// Note: make graphite an option, of course. Unfortunately it can't do
	// sub-second precision like at least Influx.
	c, err := newOpenTSDB(opts.Addr, "radio.decameter", false)
	if err != nil {
		log.Fatal("4 ", err)
	}
	
	tags := map[string]string{ "planet":"jupiter",}
	

	dec, _, err := audio.NewDecoder(f)
	if err != nil {
		log.Fatal("5 ", err)
	}
	floatz := make(audio.Float64, dec.Config().SampleRate / (1000 / opts.Resolution))
	fmt.Printf("samples per sec: %d\n", dec.Config().SampleRate)
	r := 0
	for {
		log.Printf("running %d", r)
		r++
		var t time.Time
		if opts.StartTime != "" {
			t = oTime
			oTime = oTime.Add(time.Duration(opts.Resolution) * time.Millisecond)
		} else {
			t = time.Now().UTC()
		}
		log.Printf("t is: %d", oTime.UnixNano() / int64(time.Millisecond ))
		read, _ := dec.Read(floatz)
		if read == 0 {
			break
		}

		var sq float64
		for _, v := range floatz {
			sq += math.Pow(v, 2)
		}

		ts := t.UnixNano() / int64(time.Millisecond)
		if e := c.write(tags, ts, math.Sqrt(sq / float64(len(floatz)))); e != nil {
			panic(e)
		}
	}
}
