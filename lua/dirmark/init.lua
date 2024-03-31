local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local default_file_path = "~/.dirMarks"

local M = {
    config = {
        file_path = default_file_path
    }
}
--[[
    Setup the plugin with the given options
    Args:
    - opts: table: The options for the plugin
        - file_path: string: The path to the directory marks file
]]
M.setup = function(opts)
    opts = opts or {}
    M.config.file_path = opts.file_path or vim.fn.expand(default_file_path)
    if not vim.fn.filereadable(M.config.file_path) then
        local file = io.open(M.config.file_path, "w")
        file:close()
    end
end

--[[
    Returns the directory paths from the directory marks file
    Returns:
    - table: A table of directory paths
]]
M.getDirectoryPathsFromFile = function()
    local file = io.open(M.config.file_path, "r")
    if not file then
        print("Could not open file" .. M.config.file_path)
        return {}
    end
    local t = {}
    for line in file:lines() do
        table.insert(t, line)
    end
    file:close()
    return t
end

--[[
    Opens a new telescope picker with the directories from the directory marks file
    Args:
    - opts: table: The options to pass to the picker
]]
M.dirmark = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select directory",
        finder = finders.new_table {
            results = M.getDirectoryPathsFromFile(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
    }):find()
end

--[[
    Adds a directory to the directory marks file
    Args:
    - directory: string: The directory to add
]]
M.add = function(directory)
    local file = io.open(M.config.file_path, "a")
    if not file then
        print("Could not open file" .. M.config.file_path)
        return
    end
    file:write(directory .. "\n")
    file:close()
end

--[[ 
    Adds the current directory to the directory marks file
]]
M.addCurrentDirectory = function()
    M.add(vim.fn.getcwd())
end

--[[
    Opens the directory marks file in a new buffer
]]
M.openDirMarks = function()
    vim.cmd("e " .. M.config.file_path)
end

M.setup()
return M
