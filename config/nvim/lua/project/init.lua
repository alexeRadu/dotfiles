local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local state   = require "telescope.actions.state"
local conf    = require("telescope.config").values

local projects = {
    {
        name = "ot-nxp rw610",
        path = "/mnt/c/nxp/ot-nxp",
        search_dirs = {
            "../sdk-rw610/middleware/wireless/framework",
            "../sdk-rw610/middleware/wireless/ieee-802.15.4",
            "./src/rw/rw610",
        },
    },
    {
        name = "ot-nxp k32w1",
        path = "/mnt/c/nxp/ot-nxp",
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

M.config = {
    current_loaded_project = nil,
    find_files_keys = '<leader>pf',
}

-- call :Telescope find_files on specific search_dirs
-- M.config.current_loaded_project must be set to one of the projects
-- specified in the config
function M.project_find_files()
    if M.config.current_loaded_project == nil then
        return
    end

    local project = M.config.current_loaded_project

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
    if M.config.current_loaded_project and M.config.current_loaded_project["name"] == project_name then
        actions.close(prompt_bufnr)
        print(string.format("Project %s already loaded", project_name))
        return
    end

    -- Do we need this? The list of project names is taken from the same 'projects' array so
    -- it's expected that the name will be found in the list of projects
    for _, project in ipairs(projects) do
        if project["name"] == project_name then
            M.config.current_loaded_project = project
            break
        end
    end

    project = M.config.current_loaded_project
    actions.close(prompt_bufnr)

    if project.path ~= vim.fn.getcwd() then
        -- TODO: remember the last working-directory? in case of exiting from any project
        -- maybe have a history to go bach in history to different projects/working-directories
        vim.api.nvim_set_current_dir(project.path)
    end

    -- TODO: do we need to remove the mapping before setting?
    -- what about removing the keymap set when exiting any project?
    vim.keymap.set('n', M.config.find_files_keys, M.project_find_files, {noremap = true, silent = true})
end

function M.projects()
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

return M
