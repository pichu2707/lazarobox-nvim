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
					-- you can also put keymaps in here
					-- Deshabilitar semantic tokens para evitar que el código se vea gris
					client.server_capabilities.semanticTokensProvider = nil
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						checkOnSave = {
							command = "clippy",
						},
					},
				},
			},
		}
	end,
}
