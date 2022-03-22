--vim.cmd "packadd packer.nvim"
local preset, packer = pcall(require, "packer")

if not present then
	local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

	print "Cloning packer .."
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
	{ "nvim-lua/plenary.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "nvim-telescope/telescope.nvim", requires = { {"nvim-lua/plenary.nvim"} } }
}

return require('packer').startup(function()
	for _, p in pairs(plugins) do
		use(p)
	end
end)
