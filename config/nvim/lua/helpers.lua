local M = {}

M.map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc})
end

M.get_visual = function()
    local _, ls, cs = unpack(vim.fn.getpos("v"))
    local _, le, ce = unpack(vim.fn.getpos("."))

    ls, le = math.min(ls, le), math.max(ls, le)
    cs, ce = math.min(cs, ce), math.max(cs, ce)

    return vim.api.nvim_buf_get_text(0, ls - 1, cs -1, le - 1, ce, {})[1] or ""
end

return M
