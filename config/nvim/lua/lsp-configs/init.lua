local configs = {}

for file, type in vim.fs.dir("~/.config/nvim/lua/lsp-configs") do

    if file ~= 'init.lua' then
        local _, _, cfgname = string.find(file, '([%w_-]+).lua$')
        local config = require('lsp-configs/' .. cfgname)

        configs[cfgname] = {
            cmd = config.cmd,
            settings = config.settings,
        }
    end
end

return configs
