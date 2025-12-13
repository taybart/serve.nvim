local M = {
  ch = -1,
  config = {
    status_icon = "💻",
    server = {
      address = "localhost:8005",
      rest_file = "serve.rest",
    },
    logs = {
      level = "info",
      file = vim.fn.stdpath("cache") .. "/serve.nvim.log",
      no_color = false,
    },
  },
}

local function ensure_job()
  if M.ch > 0 then
    return M.ch
  end
  local install_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
  local bin = install_dir .. "/../../go/serve"
  M.ch = vim.fn.jobstart({ bin }, { rpc = true })
  if not M.ch then
    error("could not start serve job")
  end
  return M.ch
end

local function rpc(fn, opts)
  local ok, ret = pcall(vim.fn.rpcrequest, ensure_job(), fn, opts)
  if not ok then
    vim.notify(ret, vim.log.levels.ERROR)
  end
  return ret
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  require("serve/command")("Serve", {
    default = function(args)
      if not rpc("serving") then
        rpc("config", { vim.json.encode(M.config) })
      end
      rpc("serve", args.fargs)
      if rpc("serving") then
        vim.g.serving_status = M.config.status_icon
      end
    end,
    status = function()
      vim.notify(rpc("status"))
    end,
    stop = function()
      -- stop returns serving status so false means we stopped
      if not rpc("stop") then
        vim.g.serving_status = ""
      end
    end,
  })
end

return M
