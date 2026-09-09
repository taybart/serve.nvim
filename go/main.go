package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/neovim/go-client/nvim"
	"github.com/taybart/log"
	"github.com/taybart/rest"
	"github.com/taybart/rest/server"
)

var s server.Server
var serving bool

func serve(v *nvim.Nvim, args []string) (bool, error) {
	if serving {
		v.WriteOut(fmt.Sprintf("already serving at %s/\n", config.Server.Address))
		return false, nil
	}

	confFile := config.Server.RestFile
	if _, err := os.Stat(confFile); !os.IsNotExist(err) {
		f, err := rest.NewFile(confFile)
		if err != nil {
			log.Error(err)
			return false, err
		}
		log.Debug("parsed server file")
		c, err := f.Parser.Server()
		if err != nil {
			log.Error(err)
			return false, err
		}
		config.Server.Address = c.Addr
		s = server.New(c)
	} else {
		if len(args) > 0 {
			config.Server.Address = args[0]
			log.Debug("set server address in config")
		}
		s = server.New(server.Config{
			Addr:  config.Server.Address,
			Dir:   ".",
			Cors:  true,
			Quiet: true,
		})
	}
	log.Debug("created server")

	// note on the goroutines below: errors are logged, never log.Fatal'd.
	// log.Fatal calls os.Exit, which would take down this rpc process and
	// leave the plugin talking to a dead channel for the rest of the session.

	if s.Config.TLS != "" {
		// tls setup lives in rest's Serve, so bind errors stay asynchronous here
		serving = true
		go func() {
			log.Debugf("listening to %s...\n", config.Server.Address)
			if err := s.Serve(); err != nil {
				serving = false
				log.Errorf("server fatal: %v", err)
				v.WriteErr(fmt.Sprintf("serve: %s\n", err))
			}
		}()
		return true, nil
	}

	// bind up front so "address already in use" is returned to :Serve rather
	// than surfacing after we have already reported success
	ln, err := net.Listen("tcp", config.Server.Address)
	if err != nil {
		log.Error(err)
		return false, err
	}
	serving = true
	go func() {
		log.Debugf("listening to %s...\n", config.Server.Address)
		if err := s.Server.Serve(ln); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serving = false
			log.Errorf("server fatal: %v", err)
			v.WriteErr(fmt.Sprintf("serve: %s\n", err))
		}
	}()
	return true, nil
}

func status(v *nvim.Nvim) (string, error) {
	status := "not serving"
	if serving {
		status = fmt.Sprintf("serving at %s/\n", config.Server.Address)
	}
	return status, nil
}
func isServing(v *nvim.Nvim) (bool, error) {
	return serving, nil
}

func stop(v *nvim.Nvim, args []string) (bool, error) {
	if !serving {
		v.WriteOut("server not running\n")
		return serving, nil
	}

	log.Debug("stopping serve...")
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()
	if err := s.Server.Shutdown(ctx); err != nil {
		// log.Fatal(err)
		log.Error(err)
		return serving, err
	}
	serving = false
	return serving, nil
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
	if err := v.RegisterHandler("serving", isServing); err != nil {
		log.Fatal(err)
	}
	if err := v.RegisterHandler("status", status); err != nil {
		log.Fatal(err)
	}
	if err := v.RegisterHandler("stop", stop); err != nil {
		log.Fatal(err)
	}
	if err := v.Serve(); err != nil {
		log.Fatal(err)
	}
}
