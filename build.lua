-- Build step for the go server binary.
--
-- lazy.nvim looks for `build.lua` in a plugin's root when it runs its build
-- task, *after* the plugin is cloned. That makes this the only place a build
-- can be declared that also fires on a first-time install: a `build` key in
-- this repo's `lazy.lua` is not visible to lazy.nvim until the plugin is
-- already installed, so it would be skipped on the very first run.
--
-- This must be synchronous. lazy.nvim loads and calls this file, then treats
-- the task as finished, so anything backgrounded here gets no error reporting
-- and can be killed when nvim exits. Raise an error to fail the build task.

local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")

for _, exe in ipairs({ "go", "make" }) do
  if vim.fn.executable(exe) == 0 then
    error(("serve.nvim: `%s` is required to build the server, but was not found in PATH"):format(exe), 0)
  end
end

local out, code
if vim.system then
  local res = vim.system({ "make", "all" }, { cwd = dir, text = true }):wait()
  out, code = (res.stdout or "") .. (res.stderr or ""), res.code
else -- nvim < 0.10
  out = vim.fn.system({ "sh", "-c", ("cd %s && make all"):format(vim.fn.shellescape(dir)) })
  code = vim.v.shell_error
end

if code ~= 0 then
  error(("serve.nvim: `make all` failed (exit %d)\n%s"):format(code, out), 0)
end

print(out ~= "" and out or "serve.nvim: built go/serve")
