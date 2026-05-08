return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local colors = {
			normal = "#7aa2f7",    -- Azul brillante
			insert = "#9ece6a",    -- Verde lima
			visual = "#bb9af7",    -- Púrpura
			replace = "#f7768e",   -- Rojo/Rosa
			command = "#ff9e64",   -- Naranja
			terminal = "#1abc9c",  -- Turquesa
		}

		local custom_theme = {
			normal = {
				a = { fg = "#1a1b26", bg = colors.normal, gui = "bold" },
				b = { fg = colors.normal, bg = "#3b4261" },
				c = { fg = "#a9b1d6", bg = "#1a1b26" },
			},
			insert = {
				a = { fg = "#1a1b26", bg = colors.insert, gui = "bold" },
				b = { fg = colors.insert, bg = "#3b4261" },
			},
			visual = {
				a = { fg = "#1a1b26", bg = colors.visual, gui = "bold" },
				b = { fg = colors.visual, bg = "#3b4261" },
			},
			replace = {
				a = { fg = "#1a1b26", bg = colors.replace, gui = "bold" },
				b = { fg = colors.replace, bg = "#3b4261" },
			},
			command = {
				a = { fg = "#1a1b26", bg = colors.command, gui = "bold" },
				b = { fg = colors.command, bg = "#3b4261" },
			},
			terminal = {
				a = { fg = "#1a1b26", bg = colors.terminal, gui = "bold" },
				b = { fg = colors.terminal, bg = "#3b4261" },
			},
			inactive = {
				a = { fg = "#565f89", bg = "#1a1b26" },
				b = { fg = "#565f89", bg = "#1a1b26" },
				c = { fg = "#565f89", bg = "#1a1b26" },
			},
		}

		require("lualine").setup({
			options = {
				theme = custom_theme,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						show_filename_only = true,
						hide_filename_extension = false,
						show_modified_status = true,
						mode = 2, -- 0: nombre, 1: índice, 2: nombre + índice
						symbols = {
							modified = " ●",
							alternate_file = "",
							directory = "",
						},
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "tabs" },
			},
			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = {
					{ "branch", icon = "" },
					{ "diff", symbols = { added = " ", modified = " ", removed = " " } },
					{ "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
				},
				lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
				lualine_x = {
					{
						require("config.version").get,
						icon = "󰃃 ",
						color = { fg = colors.normal },
					},
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { { "location", icon = "" } },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
