return {
	"nvim-treesitter/nvim-treesitter",
	commit = "42fc28ba918343ebfd5565147a42a26580579482",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"bash",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"python",
				"rust",
				"html",
				"css",
				"sql",
				"norg",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
