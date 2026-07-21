return {
	"danymat/neogen",
	version = "*",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = "Neogen",
	keys = {
		{
			"<leader>cd",
			function()
				require("neogen").generate()
			end,
			desc = "[C]ode [D]ocument current function",
		},
		{
			"<leader>cD",
			function()
				require("neogen").generate({ type = "class" })
			end,
			desc = "[C]ode [D]ocument current class/type",
		},
		{
			"<leader>cf",
			function()
				require("neogen").generate({ type = "file" })
			end,
			desc = "[C]ode document [F]ile",
		},
	},
	config = function()
		require("neogen").setup({
			enabled = true,
			input_after_comment = true,
			snippet_engine = "nvim",
			languages = {
				sh = {
					template = {
						annotation_convention = "google_bash",
					},
				},
				java = {
					template = {
						annotation_convention = "javadoc",
					},
				},
				javascript = {
					template = {
						annotation_convention = "jsdoc",
					},
				},
				javascriptreact = {
					template = {
						annotation_convention = "jsdoc",
					},
				},
				python = {
					template = {
						annotation_convention = "google_docstrings",
					},
				},
				rust = {
					template = {
						annotation_convention = "rustdoc",
					},
				},
				typescript = {
					template = {
						annotation_convention = "tsdoc",
					},
				},
				typescriptreact = {
					template = {
						annotation_convention = "tsdoc",
					},
				},
			},
		})
	end,
}
