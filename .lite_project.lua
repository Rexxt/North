local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local console = require "plugins.console"

command.add(nil, {
  ["project:run-project"] = function()
    core.log "Running..."
    console.run {
      command = "luajit main.lua",
      file_pattern = "(.*):(%d+):(%d+): (.*)$",
      cwd = ".",
      on_complete = function(retcode) core.log("Run complete with return code "..retcode) end,
    }
  end
})

keymap.add { ["ctrl+b"] = "project:run-project" }
