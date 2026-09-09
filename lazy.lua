-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.
--
-- If you are curious about how exactly the plugins are used, you can use e.g.
-- the search functionality on Github.
--
--https://lazy.folke.io/packages#lazy

---@module "lazy"

---@type LazySpec
return {
  {
    "taybart/serve.nvim",
    -- on a first-time install lazy.nvim has not read this file yet, so the
    -- build is driven by build.lua in the plugin root instead. this key covers
    -- later updates, where the spec is known; both run the same `make all`.
    build = "make all",
    opts = {},
    cmd = {
      "Serve",
    },
  },
}
