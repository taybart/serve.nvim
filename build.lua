local function make()
  local lines = { '' }
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local cmd = 'make all'
  local dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
  local function on_event(job_id, data, event)
    if event == 'stdout' or event == 'stderr' then
      if data then
        vim.list_extend(lines, data)
      end
    end
    if event == 'exit' then
      vim.fn.setqflist({}, ' ', { title = cmd, lines = lines })
      vim.api.nvim_command('doautocmd QuickFixCmdPost')
    end
  end
  vim.fn.jobstart(cmd, {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

make()
