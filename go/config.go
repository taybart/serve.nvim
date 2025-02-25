package main

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/neovim/go-client/nvim"
	"github.com/taybart/log"
)

type ServerConfig struct {
	Address   string `json:"address,omitempty"`
	Directory string `json:"directory,omitempty"`
}

type LogsConfig struct {
	Level   string `json:"level,omitempty"`
	File    string `json:"file,omitempty"`
	NoColor bool   `json:"no_color,omitempty"`
}

var config = struct {
	Server ServerConfig
	Logs   LogsConfig
}{
	Server: ServerConfig{
		Address:   "localhost:8005",
		Directory: ".",
	},
	Logs: LogsConfig{
		Level:   "INFO",
		NoColor: false,
	},
}

func configRPC(v *nvim.Nvim, args []string) error {
	err := json.Unmarshal([]byte(args[0]), &config)
	if err != nil {
		return err
	}
	log.SetLevel(levelFromString(config.Logs.Level))
	if err := log.SetOutput(config.Logs.File); err != nil {
		v.WriteErr(fmt.Sprintf("could not open logs file %s\n", err))
		panic(err)
	}
	if config.Logs.NoColor {
		log.UseColors(false)
	}

	return nil
}

func levelFromString(lvl string) log.Level {
	switch strings.ToUpper(lvl) {
	case "TRACE":
		return log.TRACE
	case "DEBUG":
		return log.DEBUG
	case "VERBOSE":
		return log.VERBOSE
	case "TEST":
		return log.TEST
	case "INFO":
		return log.INFO
	case "WARN":
		return log.WARN
	case "ERROR":
		return log.ERROR
	case "FATAL":
		return log.FATAL
	default:
		return log.FATAL
	}
}
