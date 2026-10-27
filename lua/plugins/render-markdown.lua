-- Reading mode renders the cursor line too, so tables and inline markup
-- stay aligned while reading. Editing mode shows raw markdown under the cursor.
local reading_mode = {
	anti_conceal = { enabled = false },
	win_options = { concealcursor = { rendered = "nc" } },
}

local base_opts
local reading = false

local function toggle_reading_mode()
	reading = not reading
	local opts = reading and vim.tbl_deep_extend("force", base_opts, reading_mode) or base_opts
	local render_markdown = require("render-markdown")
	render_markdown.setup(opts)
	render_markdown.set(true)
	vim.notify(reading and "Reading mode on" or "Editing mode on", vim.log.levels.INFO, { title = "Markdown" })
end

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	ft = { "markdown", "codecompanion" },
	keys = {
		{ "<leader>mr", toggle_reading_mode, ft = "markdown", desc = "Markdown: Toggle reading mode" },
	},
	opts = {
		pipe_table = {
			preset = "round",
			style = "full",
			cell = "padded",
		},
		anti_conceal = {
			ignore = {
				table_border = true,
			},
		},
	},
	config = function(_, opts)
		base_opts = opts
		require("render-markdown").setup(opts)
	end,
}
