return {
	"nvim-neorg/neorg",
	enabled = false,  -- Deshabilitar temporalmente hasta resolver el parser
	lazy = false,
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neorg/lua-utils.nvim", 
		"pysan3/pathlib.nvim",
		"nvim-neotest/nvim-nio",
	},
	build = ":Neorg sync-parsers",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/notas",
						},
						default_workspace = "notes",
					},
				},
			},
		})
	end,
}
