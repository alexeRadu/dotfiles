--vim.cmd "packadd packer.nvim"
local preset, packer = pcall(require, "packer")

print("Hello")

if not present then
	local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

--	print "Cloning packer .."
	vim.fn.system {
		"git",
		"clone",
		"https://github.com/wbthomason/packer.nvim",
		"--depth",
		"20",
		packer_path
	}

	vim.cmd "packadd packer.nvim"
	present, packer = pcall(require, "packer")
	if present then
	--	print "Packer cloned successfully."
	else
		error("Couldn't clone packer!\nPacker path: " .. packer_path .. "\n" .. packer)
	end
end

local plugins = {
	{"nvim-lua/plenary.nvim"},
	{"lukas-reineke/indent-blankline.nvim"}
}

require('packer').startup(function()
	for _, p in pairs(plugins) do
		use(p)
	end
end)

require("indent_blankline").setup {
	show_current_context = true,
	show_current_context_start = true,
}
