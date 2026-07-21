return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "macchiato",
				dark = "mocha",
			},
			transparent_background = true, -- fondo transparente
			float = {
				transparent = true, -- enable transparent floating windows
				solid = false, -- use solid styling for floating windows, see |winborder|
			},
			show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
			term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
				shade = "dark",
				percentage = 0.15, -- percentage of the shade to apply to the inactive window
			},
			no_italic = false, -- Force no italic
			no_bold = false, -- Force no bold
			no_underline = false, -- Force no underline
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
				loops = {},
				functions = { "italic" },
				keywords = {},
				strings = {},
				variables = { "italic" },
				numbers = {},
				booleans = { "italic" },
				properties = {},
				types = {},
				operators = {},
				-- miscs = {}, -- Uncomment to turn off hard-coded styles
			},
			lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
				virtual_text = {
					errors = { "italic" },
					hints = { "italic" },
					warnings = { "italic" },
					information = { "italic" },
					ok = { "italic" },
				},
				underlines = {
					errors = { "underline" },
					hints = { "underline" },
					warnings = { "underline" },
					information = { "underline" },
					ok = { "underline" },
				},
				inlay_hints = {
					background = true,
				},
			},
			-- Kanagawa Blur palette mapped to Catppuccin tokens
			-- Based on: github.com/Gentleman-Programming/gentleman-kanagawa-blur (blur variant)
			color_overrides = {
				all = {
					-- Backgrounds
					base = "#191E28", -- gray1 — main background
					mantle = "#191E28", -- gray1 — sidebar / statusline bg
					crust = "#232A40", -- gray2 — borders

					-- Surfaces
					surface0 = "#1C212C", -- surface0
					surface1 = "#232A36", -- surface1
					surface2 = "#2A3142", -- surface2

				-- Text
				text = "#F3F6F9", -- fg
				subtext1 = "#00FFFF", -- bright_black / fg_placeholder
				subtext0 = "#8892A4", -- gray5 / fg_muted — raised for contrast on dark bg

				-- Overlays (selection, inactive text, borders)
				overlay2 = "#8892A4", -- gray5 — raised for contrast on dark bg
				overlay1 = "#5A6480", -- gray3 — raised for contrast on dark bg
				overlay0 = "#3D4F7A", -- gray4 — raised for contrast on dark bg

					-- Accent colors (syntax)
					red = "#CB7C94", -- constant / embedded
					flamingo = "#C4746E", -- variable
					pink = "#B99BF2", -- function_
					mauve = "#C99AD6", -- keyword
					blue = "#7FB4CA", -- blue / type
					sapphire = "#A3B5D6", -- constructor / primary
					sky = "#7AA89F", -- cyan
					teal = "#A4DAA7", -- number / enum
					green = "#B7CC85", -- green
					yellow = "#FFE066", -- yellow / warnings
					peach = "#DEBA87", -- operator / orange
					lavender = "#B4BEFE", -- identifiers / selection highlight — original Catppuccin Mocha lavender
					rosewater = "#E0C15A", -- accent (gold)
				},
			},
			custom_highlights = {},
			default_integrations = true,
			auto_integrations = false,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				notify = false,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
			},
		})

		-- setup must be called before loading
		vim.cmd.colorscheme("catppuccin")
	end,
}
