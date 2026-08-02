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
			{ "<leader>c", group = "Code" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>G", group = "GitHub" },
			{ "<leader>h", group = "Harpoon / hunks" },
			{ "<leader>i", group = "Images / REPL" },
			{ "<leader>l", group = "LSP / lint / format" },
			{ "<leader>L", group = "Live server" },
			{ "<leader>m", group = "Media" },
			{ "<leader>r", group = "Run snippets" },
			{ "<leader>R", group = "Rust" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>w", group = "Windows" },
			{ "<leader>x", group = "Execute file" },
		})
	end,
}
