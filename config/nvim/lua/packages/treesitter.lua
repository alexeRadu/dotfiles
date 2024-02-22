local M = {}

M.name = "nvim-treesitter.configs"
M.config = {
    ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "python",
        "bash",
        "cmake",
        "make",
        "ninja",
        "diff",
        "gitattributes",
        "gitcommit",
        "json",
        "markdown",
        "java",
        "javascript",
        "typescript",
        "html",
        "http",
        "css",
    },
    auto_install = true,
    sync_install = false,
    highlight = {
      enable = true,
      -- use_languagetree = true,
      -- additional_vim_regex_highlighting = false,
    },
    indents = {
        enable = true,
    },
    playground = {
      enable = true
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = {"BufWrite", "CursorHold"},
    },
}

return M
