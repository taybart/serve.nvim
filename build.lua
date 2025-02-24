local winnr = vim.fn.win_getid()
local bufnr = vim.api.nvim_win_get_buf(winnr)
local dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')

local function on_event(_, data, event)
  if event == 'stdout' or event == 'stderr' then
    if data then
      vim.print(data)
    end
  end
end
vim.fn.jobstart('cd ' .. dir .. ' && make', {
  on_stderr = on_event,
  on_stdout = on_event,
  on_exit = on_event,
  stdout_buffered = true,
  stderr_buffered = true,
})
