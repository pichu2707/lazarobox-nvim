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

					map("<leader>Rd", vim.diagnostic.open_float, "Rust: show diagnostic")
					map("<leader>Rj", vim.diagnostic.goto_next, "Rust: next diagnostic")
					map("<leader>Rk", vim.diagnostic.goto_prev, "Rust: previous diagnostic")
					map("<leader>Rq", vim.diagnostic.setloclist, "Rust: list diagnostics")
					map("<leader>Rc", "<cmd>RustLsp flyCheck run<cr>", "Rust: run flyCheck")
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
