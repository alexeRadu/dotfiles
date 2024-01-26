local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local state   = require "telescope.actions.state"
local conf    = require("telescope.config").values
local config  = require("project.config").config
local lsp     = require("project.lsp")
local nt_api  = require("nvim-tree.api")

local projects = {
    {
        name         = "ot-nxp mcxw72",
        path         = "/mnt/c/nxp/ot-nxp",
        file_pattern = {"*c", "*cpp", "*cc", "*hpp","*h"},
        search_dirs  = {
            "../sdk-mcxw72/middleware/wireless/ieee-802.15.4",
            "../sdk-mcxw72/middleware/wireless/framework",
            "../sdk-mcxw72/rtos/freertos",
            "../sdk-mcxw72/devices/MCXW72BD",
            "../sdk-mcxw72/boards/k32w148evk",
            "../sdk-mcxw72/platform/drivers/ctimer",
            "../sdk-mcxw72/components/timer",
            "../sdk-mcxw72/components/serial_manager",
            "../sdk-mcxw72/components/mem_manager",
            "../sdk-mcxw72/components/messaging",
            "../sdk-mcxw72/components/lists",
            "../sdk-mcxw72/components/osa",
            "../sdk-mcxw72/components/uart",
            "../sdk-mcxw72/components/rpmsg",
            "../sdk-mcxw72/components/rng",
            "../sdk-mcxw72/components/flash",
            "../sdk-mcxw72/components/timer_manager",
            "../sdk-mcxw72/components/timer",
            "../sdk-mcxw72/components/conn_fwloader",
            "../sdk-mcxw72/middleware/wireless/framework/FunctionLib",
            "../sdk-mcxw72/middleware/wireless/framework/FileSystem",
            "../sdk-mcxw72/middleware/wireless/framework/platform/rdrw610",
            "../sdk-mcxw72/middleware/littlefs",
            "./src/rw/mcxw72",
            "./src/common",
            "./openthread",
        },
        lsp = {
            name         = 'clangd',
            cmd          = {'clangd-12', '--compile-commands-dir=build_rw610'},
            file_pattern = {"*c", "*cpp", "*cc", "*hpp","*h"},
        },
    },
    {
        name         = "ot-nxp rw610",
        path         = "/mnt/c/nxp/ot-nxp",
        file_pattern = {"*c", "*cpp", "*cc", "*hpp","*h"},
        search_dirs  = {
            "../sdk-rw610/middleware/wireless/ieee-802.15.4",
            "../sdk-rw610/middleware/wireless/framework",
            "../sdk-rw610/rtos/freertos",
            "../sdk-rw610/devices/RW610",
            "../sdk-rw610/boards/rdrw610",
            "../sdk-rw610/platform/drivers/ctimer",
            "../sdk-rw610/components/timer",
            "../sdk-rw610/components/serial_manager",
            "../sdk-rw610/components/mem_manager",
            "../sdk-rw610/components/messaging",
            "../sdk-rw610/components/lists",
            "../sdk-rw610/components/osa",
            "../sdk-rw610/components/uart",
            "../sdk-rw610/components/rpmsg",
            "../sdk-rw610/components/rng",
            "../sdk-rw610/components/flash",
            "../sdk-rw610/components/timer_manager",
            "../sdk-rw610/components/timer",
            "../sdk-rw610/components/conn_fwloader",
            "../sdk-rw610/middleware/wireless/framework/FunctionLib",
            "../sdk-rw610/middleware/wireless/framework/FileSystem",
            "../sdk-rw610/middleware/wireless/framework/platform/rdrw610",
            "../sdk-rw610/middleware/littlefs",
            "./src/rw/rw610",
            "./src/common",
            "./openthread",
        },
        lsp = {
            name         = 'clangd',
            cmd          = {'clangd-12', '--compile-commands-dir=build_rw610'},
            file_pattern = {"*c", "*cpp", "*cc", "*hpp","*h"},
        },
    },
    {
        name         = "ot-nxp k32w1",
        path         = "/mnt/c/nxp/ot-nxp",
        search_dirs  = {
            "../sdk-k32w1/middleware/wireless/framework",
            "../sdk-k32w1/middleware/wireless/ieee-802.15.4",
            ".",
        },
        lsp = {
            name         = 'clangd',
            cmd          = {'clangd-12', '--compile-commands-dir=build_k32w1'},
            file_pattern = {"*c", "*cpp", "*cc", "*hpp","*h"},
        },
    },
    {
        name         = "nvim-config",
        path         = "~/.config/nvim",
        search_dirs  = { "." },
        lsp          = {
            name         = "lua-language-lsp",
            file_pattern = { "*.lua" },
            cmd          = {'/home/radu/code/lua-language-server/bin/lua-language-server'},
            settings     = {
            }
        },
    },
    {
        name         = "project-nvim",
        path         = "~/dotfiles/config/nvim/lua/project",
        search_dirs  = { "~/dotfiles/config/nvim/lua/project" },
        lsp = {
            name         = "lua-language-lsp",
            cmd          = {'/home/radu/code/lua-language-server/bin/lua-language-server'},
            file_pattern = { "*.lua" },
            settings     = {
            }
        }
    }
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

function project_grep()
    local project = config.current_loaded_project
    if project == nil then
        return
    end

    require("telescope.builtin.__files").live_grep({
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
            config.current_loaded_project = vim.deepcopy(project)
            break
        end
    end

    project = config.current_loaded_project
    actions.close(prompt_bufnr)

    if project.path ~= vim.fn.getcwd() then
        vim.api.nvim_set_current_dir(project.path)
    end

    -- remove any directories that don't exist
    search_dirs = {}
    for _, path in ipairs(project.search_dirs) do
        if vim.fn.isdirectory(path) == 1 then
            search_dirs[#search_dirs + 1] = path
        else
            print(string.format("Path '%s' is not a valid directory", path))
        end
    end

    if config.update_nvim_tree then
        nt_api.tree.change_root(project.path)
        nt_api.tree.reload()
    end

    vim.keymap.set('n', config.find_files_keys, project_find_files, {noremap = true, silent = true})
    vim.keymap.set('n', config.grep_keys, project_grep, {noremap = true, silent = true})

    lsp.enable()
end

function M.list_projects()
    local opts = {}
    local project_names = {}

    for _, project in ipairs(projects) do
        project_names[#project_names + 1] = project["name"]
    end

    pickers.new(opts, {
        prompt_title     = "Project Select",
        layout_strategy  = "center",
        sorting_strategy = "ascending",
        finder           = finders.new_table({ results = project_names }),
        sorter           = conf.generic_sorter(opts),
        previewer        = false,
        attach_mappings  = function(prompt_bufnr, map)
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
