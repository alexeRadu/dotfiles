local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local state   = require "telescope.actions.state"
local conf    = require("telescope.config").values
local config  = require("project.config").config
local lsp     = require("project.lsp")

local projects = {
    {
        name = "ot-nxp rw610",
        path = "/mnt/c/nxp/ot-nxp",
        build_dir = "build_rw610",
        search_dirs = {
            "../sdk-rw610/middleware/wireless/ieee-802.15.4",
            "../sdk-rw610/middleware/wireless/framework",
            "./src/rw/rw610",
        },
    },
    {
        name = "ot-nxp k32w1",
        path = "/mnt/c/nxp/ot-nxp",
        build_dir = "build_k32w1",
        search_dirs = {
            "../sdk-k32w1/middleware/wireless/framework",
            "../sdk-k32w1/middleware/wireless/ieee-802.15.4",
            ".",
        },
    },
    {
        name = "project.nvim",
        path = "~/.config/nvim",
        search_dirs = {
            ".",
        },
    },
}

local M = {}


function project_find_files()
    local project = config.current_loaded_project
    if project == nil then
        return
    end

    require("telescope.builtin.__files").find_files({
        search_dirs = project.search_dirs,
    })
end

local function open_project(prompt_bufnr)
    local selected_entry = state.get_selected_entry(prompt_bufnr)
    if selected_entry == nil then
        actions.close(prompt_bufnr)
        return
    end

    project_name = selected_entry.value
    if config.current_loaded_project and config.current_loaded_project["name"] == project_name then
        actions.close(prompt_bufnr)
        print(string.format("Project %s already loaded", project_name))
        return
    end

    for _, project in ipairs(projects) do
        if project["name"] == project_name then
            config.current_loaded_project = project
            break
        end
    end

    project = config.current_loaded_project
    actions.close(prompt_bufnr)

    if project.path ~= vim.fn.getcwd() then
        vim.api.nvim_set_current_dir(project.path)
    end

    vim.keymap.set('n', config.find_files_keys, project_find_files, {noremap = true, silent = true})

    lsp.enable()
end

function M.list_projects()
    local opts = {}
    local project_names = {}

    for _, project in ipairs(projects) do
        project_names[#project_names + 1] = project["name"]
    end

    pickers.new(opts, {
        prompt_title = "Select a Projects",
        finder       = finders.new_table({ results = project_names }),
        sorter       = conf.generic_sorter(opts),
        previewer    = false,
        attach_mappings = function(prompt_bufnr, map)
            local function on_project_selected()
                open_project(prompt_bufnr)
            end

            actions.select_default:replace(on_project_selected)

            return true
        end
    }):find()
end

function M.quit_project()
end

return M
