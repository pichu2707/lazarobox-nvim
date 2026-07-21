return {
	"barrett-ruth/live-server.nvim",
	build = "npm install -g live-server",
	cmd = { "LiveServerStart", "LiveServerStop" },
	keys = {
		{
			"<leader>Ls",
			function()
				vim.cmd("LiveServerStart")
				-- Wait for server to be ready, then open browser (Linux)
				vim.defer_fn(function()
					vim.fn.jobstart({ "xdg-open", "http://localhost:5500" }, { detach = true })
				end, 500)
			end,
			desc = "Start live server + open browser",
		},
		{ "<leader>Lx", "<cmd>LiveServerStop<CR>", desc = "Stop live server" },
	},
	config = function()
		require("live-server").setup({
			args = { "--port=5500", "--no-browser" },
		})
	end,
}

