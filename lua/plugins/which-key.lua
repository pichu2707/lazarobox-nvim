return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Show buffer keymaps",
		},
	},
	config = function()
		local wk = require("which-key")

		wk.setup({})

		wk.add({
			{ "<leader>a", group = "AI" },
			{ "<leader>b", group = "Buffers" },
			{ "<leader>c", group = "Code", mode = { "n", "v" } },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>G", group = "GitHub" },
			{ "<leader>h", group = "Harpoon / hunks" },
			{ "<leader>i", group = "Images / REPL" },
			{ "<leader>l", group = "LSP / lint / format" },
			{ "<leader>L", group = "Live server" },
			{ "<leader>m", group = "Media" },
			{ "<leader>O", group = "OpenCode" },
			{ "<leader>r", group = "Rename" },
			{ "<leader>R", group = "Rust" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>w", group = "Windows" },
		})
	end,
}
