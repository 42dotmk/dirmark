local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local tscopeConfig = require("telescope.config").values
local dirsFile = "/home/halicea/.dirMarks"

-- our picker function: colors
local getDirectoryPathsFromFile = function()
    local file = io.open(dirsFile, "r")
    local t = {}
    -- if not file then return t end
    for line in file:lines() do
        table.insert(t, line)
    end
    file:close()
    return t
end

local dirmark = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Select directory",
    finder = finders.new_table {
      results = getDirectoryPathsFromFile(),
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end
    },
    sorter = tscopeConfig.generic_sorter(opts),
  }):find()
end

local add = function(directory)
    local file = io.open(dirsFile, "a")
    local t = {}
    file:write(directory .. "\n")
    file:close()
end

local addCurrentDirectory = function()
    add(vim.fn.getcwd())
end

local openDirMarks = function() 
    vim.cmd("e " .. dirsFile) 
end

return {
    dirmark = dirmark,
    add = add,
    addCurrentDirectory = addCurrentDirectory,
    openDirMarks = openDirMarks
}
