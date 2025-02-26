-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.
--
-- If you are curious about how exactly the plugins are used, you can use e.g.
-- the search functionality on Github.
--
--https://lazy.folke.io/packages#lazy

---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  {
    'taybart/serve.nvim',
    opts = {
      server = {
        address = 'localhost:8005',
        directory = '.',
      },
      logs = {
        level = 'INFO',
        file = vim.fn.stdpath('cache') .. '/serve.nvim.log',
        no_color = false,
      },
    },
    cmd = {
      'Serve',
      'ServeStop',
    },
  },
}
