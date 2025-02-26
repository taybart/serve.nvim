local M = {
  ch = nil,
  config = {
    status_icon = '💻',
    server = {
      address = 'localhost:8005',
      directory = '.',
    },
    logs = {
      level = 'info',
      file = vim.fn.stdpath('cache') .. '/serve.nvim.log',
      no_color = false,
    },
  },
}

local function ensure_job()
  if M.ch then
    return M.ch
  end
  local install_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
  local bin = install_dir .. '/../../go/serve'
  M.ch = vim.fn.jobstart({ bin }, { rpc = true })

  return M.ch
end

local function set_config()
  local c = M.config
  local no_color = 'false'
  if c.logs.no_color then
    no_color = 'true'
  end
  local json = '{'
    .. '"server":{'
    .. '"address": "'
    .. c.server.address
    .. '",'
    .. '"directory": "'
    .. c.server.directory
    .. '"'
    .. '},'
    .. '"logs": {'
    .. '"level": "'
    .. c.logs.level
    .. '",'
    .. '"file": "'
    .. c.logs.file
    .. '",'
    .. '"no_color": '
    .. no_color
    .. '}}'
  vim.fn.rpcrequest(ensure_job(), 'config', { json })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts)
  -- set_config()

  vim.api.nvim_create_user_command('Serve', function(args)
    set_config()
    vim.g.serving_status = M.config.status_icon
    vim.fn.rpcrequest(ensure_job(), 'serve', args.fargs)
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('ServeStatus', function(args)
    set_config()
    vim.fn.rpcrequest(ensure_job(), 'status', args.fargs)
  end, {})
  vim.api.nvim_create_user_command('ServeStop', function(args)
    set_config()
    vim.g.serving_status = ''
    vim.fn.rpcrequest(ensure_job(), 'stop', args.fargs)
  end, {})
end

return M
