local api     = vim.api
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf    = require("telescope.config").values

local M = {}

M.unload_module = function (name)
    for module, _ in pairs(package.loaded) do
        if string.find(module, name, 1, true) then
            package.loaded[module] = nil
        end
    end
end

M.show_loaded_packages = function(opts)
    opts = opts or {}

    modules = {}
    for module, _ in pairs(package.loaded) do
        modules[#modules + 1] = module
    end

    pickers.new(opts,  {
        prompt_title = "Packages",
        finder       = finders.new_table({ results = modules }),
        sorter       = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            map("i", "<c-u>", function(_)
                local entry = require("telescope.actions.state").get_selected_entry()
                local module = entry[1]

                package.loaded[module] = nil
                -- print(vim.inspect(entry))
            end)

            return true
        end
    }):find()
end

api.nvim_create_autocmd({"BufWritePost"}, {
    group    = api.nvim_create_augroup("modules", { clear = true }),
    pattern  = "*.lua",
    callback = function ()
        local path = api.nvim_buf_get_name(0)
        local stdpath = api.nvim_eval('stdpath("data")')

        if string.match(path, stdpath) then
            local modulename = string.match(path, "([_%-%w]*)%.lua$")

            for m, _ in pairs(package.loaded) do
                -- the condition is that the module has to contain the name of the file
                -- and has to be in the path of the file
                if string.find(m, modulename) and string.find(path, m) then
                    package.loaded[m] = nil
                end
            end
        end
    end
})

return M
