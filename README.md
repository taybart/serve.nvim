# serve.nvim

Quick local server for current directory

## Install

You will need `go` and `make` installed on your computer

## Configuration

```lua
{
    'taybart/serve.nvim',
    build = 'make all', -- important step
    opts = {
        status_icon = '💻',
        server = {
            address = 'localhost:8005',
            rest_file = 'serve.rest',
        },
        logs = {
            enabled = true,
            level = 'info',
            file = vim.fn.stdpath('cache') .. '/serve.nvim.log',
            no_color = false,
        },
    },
}
```

### status line

The global variable `g:serving_status` will be set to `config.status_icon` when the server is active

You can add it to [lualine](https://github.com/nvim-lualine/lualine) for instance `sections = { lualine_y = { 'g:serving_status' } }`

## Usage

`Serve [addr]` will serve the current directory at either `[addr]` or by default `localhost:8005`

`Serve status` gives back the current status

`Serve stop` stop serving directory

### Rest file

Serve will read a file named `serve.rest` in the current directory. If it exists, it will be used as the server configuration.

The file format is a [rest](https://github.com/taybart/rest/blob/v0.7.3/doc/SERVER.md#server-rest-file) file. Here is an example:

```hcl
server {
    address = "localhost:8005"
    directory = "."
    cors = true
    quiet = true
    // optional, enable redirects to index.html instead of 404
    spa = true
}
```

this serves vim's cwd at `localhost:8005` with CORS enabled. Quiet mode is also enabled to prevent logs we don't care about in the logs file.
