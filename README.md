# serve.nvim

Quick local server for current directory

## Install

You will need go and make installed on your computer

## Configuration

```lua
{
  'taybart/serve.nvim',
  opts = {
    status_icon = '💻',
    server = {
      address = 'localhost:8005',
      directory = '.',
    },
    logs = {
      level = 'info',
      file = vim.fn.stdpath('data') .. '/serve.nvim.log',
    },
  },
}
```

### status line

The global variable `g:serving_status` will be set to `config.status_icon` when the server is active

You can add it to [lualine](https://github.com/nvim-lualine/lualine) for instance `sections = { lualine_y = { 'g:serving_status' } }`

## Usage

`Serve [addr]` will serve the current directory at either `[addr]` or by default `localhost:8005`

`ServeStatus` gives back the current status

`ServeStop` stop serving directory
