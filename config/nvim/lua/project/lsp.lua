local config = require("project.config").config

local M = {}

local group = nil
local autocmd = nil

function M.enable()
    local project = config.current_loaded_project
    if project == nil then
        return
    end

    if project.lsp == nil or project.lsp.name == nil or project.lsp.cmd == nil then
        return
    end

    group = vim.api.nvim_create_augroup("Project", { clear = true })

    autocmd = vim.api.nvim_create_autocmd({"BufEnter"}, {
        pattern  = {"*c", "*h"},
        group    = group,
        callback = function()
            vim.lsp.start({
                name     = project.lsp.name,
                cmd      = project.lsp.cmd,
                root_dir = project.path,
            })
        end,
    })
end

function M.disable()
    if autocmd ~= nil then
        nvim_del_autocmd(autocmd)
    end

    if group ~= nil then
        nvim_del_augroup_by_id(group)
    end
end

return M
