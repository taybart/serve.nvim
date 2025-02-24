package main

import (
	"context"
	"net/http"
	"time"

	"github.com/neovim/go-client/nvim/plugin"
	"github.com/taybart/log"
	"github.com/taybart/rest/server"
)

type Config struct {
	Addr string
	Dir  string
	Dump bool
}

var stop chan bool

func config(c Config) Config {
	config := Config{
		Addr: "localhost:8005",
		Dir:  ".",
		Dump: false,
	}
	if c.Addr != "" {
		config.Addr = c.Addr
	}
	if c.Dir != "" {
		config.Dir = c.Dir
	}
	config.Dump = c.Dump
	return config
}

func serve(args []string) *http.Server {
	log.Debugf("args %+v", args)
	return nil

	log.Debugf("starting serve", args)
	//TODO: do something to make config from args
	c := config(Config{})

	s := server.New(server.Config{
		Addr: c.Addr,
		Dir:  c.Dir,
		Dump: c.Dump,
	})
	log.Debugf("listening to %s...\n", c.Addr)
	go func() {
		if err := s.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalf("server fatal: %v", err)
		}
	}()
	return &s
}

func main() {
	if err := log.SetOutput("./log.txt"); err != nil {
		panic(err)
	}
	var s *http.Server
	plugin.Main(func(p *plugin.Plugin) error {
		p.HandleCommand(&plugin.CommandOptions{Name: "Serve"}, func(p *plugin.Plugin, args []string) {
			s = serve(args)
		})
		p.HandleCommand(&plugin.CommandOptions{Name: "ServeStop"}, func() {
			defer func() {
				if err := log.Close(); err != nil {
					log.Error(err)
				}
			}()
			log.Debug("stopping serve...")
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
			defer cancel()
			if err := s.Shutdown(ctx); err != nil {
				log.Fatal(err)
			}
		})
		return nil
	})
}
