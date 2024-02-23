local config = {}

local cmd = os.getenv("LSP_LUA_SERVER")
if cmd == nil then
    config.cmd = nil
else
    config.cmd = {cmd}
end

config.settings = {
    Lua = {
        runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ';'),
        },
        diagnostics = {
            globals = {'vim'}
        },
        workspace = {
            library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            }
        }
    },
}

return config
