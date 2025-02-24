local chan

local function ensure_job()
  if chan then
    return chan
  end
  chan = vim.fn.jobstart({ 'serve' }, { rpc = true })
  return chan
end

vim.api.nvim_create_user_command('Serve', function(args)
  vim.fn.rpcrequest(ensure_job(), 'serve', args.fargs)
end, { nargs = '*' })
