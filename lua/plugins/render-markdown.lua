return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	ft = { "markdown", "codecompanion" },
	opts = {
		pipe_table = {
			preset = "round",
			style = "full",
			cell = "padded",
		},
		anti_conceal = {
			ignore = {
				table_border = true,
			},
		},
	},
}
