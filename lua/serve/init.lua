local M = {
  ch = -1,
  config = {
    status_icon = "💻",
    server = {
      address = "localhost:8005",
      rest_file = "serve.rest",
    },
    logs = {
      enabled = true,
      level = "info",
      file = vim.fn.stdpath("cache") .. "/serve.nvim.log",
      no_color = false,
    },
  },
}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
end

local function ensure_job()
  if M.ch > 0 then
    return M.ch
  end

  local root = plugin_root()
  local bin = root .. "/go/serve"
  if vim.fn.executable(bin) == 0 then
    error(
      ("serve.nvim: server binary not built (%s)\nrun `:Lazy build serve.nvim`, or `make all` in %s"):format(bin, root),
      0
    )
  end

  local ok, ch = pcall(vim.fn.jobstart, { bin }, {
    rpc = true,
    -- the server exits on a fatal error (a port already in use, say). drop the
    -- stale channel so the next command starts a fresh one instead of talking
    -- to a dead job for the rest of the session.
    on_exit = function()
      M.ch = -1
      vim.g.serving_status = ""
    end,
  })
  if not ok then
    error("serve.nvim: could not start serve job: " .. tostring(ch), 0)
  end
  if ch <= 0 then
    error("serve.nvim: could not start serve job (jobstart returned " .. tostring(ch) .. ")", 0)
  end

  M.ch = ch
  return M.ch
end

local function rpc(fn, opts)
  local ok, ret = pcall(function()
    return vim.fn.rpcrequest(ensure_job(), fn, opts)
  end)
  if not ok then
    vim.notify(ret, vim.log.levels.ERROR)
    return nil
  end
  return ret
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  require("serve/command")("Serve", {
    default = function(args)
      local already_serving = rpc("serving")
      if not already_serving then
        rpc("config", { vim.json.encode(M.config) })
      end
      -- serve reports whether it started, so the icon does not depend on
      -- winning a race with the server goroutine
      if rpc("serve", args.fargs) or already_serving then
        vim.g.serving_status = M.config.status_icon
      end
    end,
    status = function()
      local status = rpc("status")
      if status then
        vim.notify(status)
      end
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
