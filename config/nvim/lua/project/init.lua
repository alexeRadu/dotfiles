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
            ".",
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
}

local M = {}

M.config = {
    current_loaded_project = nil,
}


local function open_project(prompt_bufnr)
    local selected_entry = state.get_selected_entry(prompt_bufnr)
    if selected_entry == nil then
        actions.close(prompt_bufnr)
        return
    end

    project_name = selected_entry.value
    if M.config.current_loaded_project and M.config.current_loaded_project["name"] == project_name then
        print(string.format("Project %s already loaded", project_name))
        actions.close(prompt_bufnr)
        return
    end

    for _, project in ipairs(projects) do
        if project["name"] == project_name then
            M.config.current_loaded_project = project
            break
        end
    end

    -- TODO: change current directory using project[path]
    -- TODO: use project[search_dir} for Telescope

    actions.close(prompt_bufnr)
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
