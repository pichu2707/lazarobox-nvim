return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		strategies = {
			chat = {
				adapter = "ollama", -- Por defecto usa Ollama local
			},
			inline = {
				adapter = "ollama",
			},
			agent = {
				adapter = "anthropic", -- Agentes requieren modelo más capaz
			},
		},
		adapters = {
			anthropic = function()
				return require("codecompanion.adapters").extend("anthropic", {
					env = {
						api_key = "ANTHROPIC_API_KEY",
					},
				})
			end,
			ollama = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = {
						model = {
							default = "qwen2.5-coder:7b", -- Cambia al modelo que tengas
						},
					},
				})
			end,
		},
	},
	keys = {
		{ "<leader>cot", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion: Toggle Chat" },
		{ "<leader>coa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion: Actions" },
		{ "<leader>coi", "<cmd>CodeCompanion<cr>", desc = "CodeCompanion: Inline" },
		{ "<leader>coc", "<cmd>CodeCompanionChat anthropic<cr>", desc = "CodeCompanion: Chat Claude" },
	},
}
