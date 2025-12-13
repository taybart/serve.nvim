return function(command_name, cmds)
  local function complete(arg_lead)
    local commands = {}
    for name in pairs(cmds) do
      if name ~= "default" then
        table.insert(commands, name)
      end
    end
    vim.print(commands)

    local pattern = arg_lead:gsub("(.)", function(c)
      return string.format("%s[^%s]*", c:lower(), c:lower())
    end)
    -- Case-insensitive fuzzy matching
    local matches = {}
    for _, command in ipairs(commands) do
      if string.find(command:lower(), pattern) then
        table.insert(matches, command)
      end
    end
    return matches
  end
  vim.api.nvim_create_user_command(command_name, function(opts)
    local args = vim.split(opts.args, "%s+", { trimempty = true })
    local command = args[1]
    -- Default
    if #args == 0 or not cmds[command] then
      cmds["default"](opts)
      return
    end

    -- local command = args[1]
    table.remove(args, 1) -- Remove command
    if type(cmds[command]) == "function" then
      cmds[command](opts)
    elseif cmds[command].basic then
      cmds[command].cb(args)
    else
      cmds[command].cb(opts)
    end
  end, {
    nargs = "*",
    bang = true,
    complete = complete,
  })
end
