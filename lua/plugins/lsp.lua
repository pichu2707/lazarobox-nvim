return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"brayden/blink.cmp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local capabilities = require('blink.cmp').get_lsp_capabilities()

		-- Configuración de diagnósticos
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				source = "if_many",
			},
			float = {
				source = "always",
				border = "rounded",
				header = "",
				prefix = "",
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- TypeScript/React
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			init_options = {
				preferences = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		})

		-- Emmet para JSX/TSX
		lspconfig.emmet_language_server.setup({
			capabilities = capabilities,
			filetypes = {
				"css", "html", "javascript", "javascriptreact",
				"typescript", "typescriptreact",
			},
		})

		-- CSS
		lspconfig.cssls.setup({
			capabilities = capabilities,
		})

		-- HTML
		lspconfig.html.setup({
			capabilities = capabilities,
		})

		-- Python
		lspconfig.pylsp.setup({
			capabilities = capabilities,
			settings = {
				pylsp = {
					plugins = {
						jedi = {
							extra_paths = { "src" },
						},
					},
				},
			},
		})

		-- Astro
		lspconfig.astro.setup({
			capabilities = capabilities,
		})

		-- SQL
		lspconfig.sqlls.setup({
			capabilities = capabilities,
		})

		-- Markdown
		lspconfig.markdown_oxide.setup({
			capabilities = capabilities,
		})
	end,
}
