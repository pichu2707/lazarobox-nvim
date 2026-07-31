return {
	"mrcjkb/rustaceanvim",
	version = "^5", -- Recommended
	lazy = false, -- This plugin is already lazy
	init = function()
		vim.g.rustaceanvim = {
			-- Plugin configuration
			tools = {
				hover_actions = {
					auto_focus = true,
				},
			},
			-- LSP configuration
			server = {
				on_attach = function(client, bufnr)
					-- Deshabilitar semantic tokens para evitar que el código se vea gris
					client.server_capabilities.semanticTokensProvider = nil

					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
					end

					map("<leader>rd", vim.diagnostic.open_float, "Rust: show diagnostic")
					map("<leader>rj", vim.diagnostic.goto_next, "Rust: next diagnostic")
					map("<leader>rk", vim.diagnostic.goto_prev, "Rust: previous diagnostic")
					map("<leader>rq", vim.diagnostic.setloclist, "Rust: list diagnostics")
					map("<leader>rC", "<cmd>RustLsp flyCheck run<cr>", "Rust: run flyCheck")
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						checkOnSave = true,
						check = {
							command = "clippy",
						},
					},
				},
			},
		}
	end,
}
