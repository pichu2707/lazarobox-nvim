return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				-- JavaScript/TypeScript con Biome como primera opción, Prettier como fallback
				javascript = { "biome", "prettier" },
				typescript = { "biome", "prettier" },
				javascriptreact = { "biome", "prettier" },
				typescriptreact = { "biome", "prettier" },

				-- Otros lenguajes
				json = { "biome", "prettier" },
				jsonc = { "biome", "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
				python = { "black", "isort" },
				lua = { "stylua" },
				sql = { "sql-formatter" },
			},

			-- Configuraciones específicas para formatters
			formatters = {
				biome = {
					condition = function(ctx)
						-- Solo usar Biome si existe biome.json en el proyecto
						return vim.fs.find({ "biome.json", "biome.jsonc" }, {
							path = ctx.filename,
							upward = true,
						})[1]
					end,
				},
				prettier = {
					condition = function(ctx)
						-- Usar Prettier si no hay Biome o como fallback
						return not vim.fs.find({ "biome.json", "biome.jsonc" }, {
							path = ctx.filename,
							upward = true,
						})[1]
					end,
				},
			},

			-- Formato automático al guardar
			format_on_save = {
				-- Timeout en milisegundos
				timeout_ms = 500,
				-- Si true, usará todos los formatters disponibles
				-- Si false, solo el primero que funcione
				lsp_fallback = true,
			},
		})

		-- Keymaps
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })

		-- Toggle formato automático
		vim.keymap.set("n", "<leader>mf", function()
			if conform.will_fallback_lsp() then
				print("Format on save: ON (LSP fallback)")
			else
				print("Format on save: ON (conform)")
			end
		end, { desc = "Check format on save status" })

		-- Formatear solo con Biome
		vim.keymap.set("n", "<leader>mb", function()
			conform.format({ formatters = { "biome" } })
		end, { desc = "Format with Biome only" })

		-- Formatear solo con Prettier
		vim.keymap.set("n", "<leader>mP", function()
			conform.format({ formatters = { "prettier" } })
		end, { desc = "Format with Prettier only" })
	end,
}

