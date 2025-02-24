package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/neovim/go-client/nvim"
	"github.com/taybart/log"
	"github.com/taybart/rest/server"
)

var s http.Server

func serve(v *nvim.Nvim, args []string) error {
	log.Debugf("starting serve %v", args)

	if len(args) > 0 {
		config.Server.Address = args[0]
	}
	s = server.New(server.Config{
		Addr: config.Server.Address,
		Dir:  config.Server.Directory,
	})
	log.Debugf("listening to %s...\n", config.Server.Address)
	go func() {
		if err := s.ListenAndServe(); err != http.ErrServerClosed {
			v.WriteErr(fmt.Sprintf("%s\n", err))
			log.Fatalf("server fatal: %v", err)
		}
	}()
	return nil
}

func stop(v *nvim.Nvim, args []string) error {
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
	return nil
}

func setupNvim() *nvim.Nvim {
	// Direct writes by the application to stdout garble the RPC stream.
	// Redirect the application's direct use of stdout to stderr.
	stdout := os.Stdout
	os.Stdout = os.Stderr
	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		log.Fatal(err)
	}
	return v
}

func main() {
	v := setupNvim()

	if err := v.RegisterHandler("config", configRPC); err != nil {
		log.Fatal(err)
	}
	if err := v.RegisterHandler("serve", serve); err != nil {
		log.Fatal(err)
	}
	if err := v.RegisterHandler("stop", stop); err != nil {
		log.Fatal(err)
	}

	if err := v.Serve(); err != nil {
		log.Fatal(err)
	}
}
