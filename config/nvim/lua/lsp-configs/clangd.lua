local config = {}

local cmd = os.getenv("LSP_CLANGD_SERVER")
if cmd == nil then
    config.cmd = nil
else
    config.cmd = {cmd}
end
config.settings = {}

return config
