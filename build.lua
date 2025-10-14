-- FIXME: i don't think this works
local dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
vim.fn.jobstart('cd ' .. dir .. ' && make all')
