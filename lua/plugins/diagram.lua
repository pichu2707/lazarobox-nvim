return {
	"3rd/diagram.nvim",
	dependencies = {
		"3rd/image.nvim",
	},
	opts = function()
		return {
			integrations = {
				require("diagram.integrations.markdown"),
			},
			renderer_options = {
				mermaid = {
					theme = "default",
					scale = 1,
				},
			},
		}
	end,
	keys = {
		{
			"K",
			function()
				require("diagram").show_diagram_hover()
			end,
			mode = "n",
			ft = { "markdown" },
			desc = "Show diagram in new tab",
		},
	},
}
