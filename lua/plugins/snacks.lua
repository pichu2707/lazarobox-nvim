return {
	"folke/snacks.nvim",
	-- commit = "bc0630e", -- Descomenta esta línea si usas Neovim < 0.10
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠒⠒⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⡘⠰⣄⡀⠀⠀⠀⠀⠀⠀⠠⢠⡴⠒⠤⠃⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡍⢿⣦⠡⠉⠑⠦⠀⠀⠀⠀⣇⣿⡧⠀⠈⢿⣌⠡⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡘⣿⠂⢀⣀⠖⠋⠉⢀⠺⣿⣿⡗⠀⠀⠈⣻⣷⠂⠙⢦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠼⢃⣠⠖⠋⠀⠀⠀⠀⠀⠀⠛⣿⡗⠀⠀⠀⢼⠛⡇⠀⠀⠻⢿⣗⣂⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡞⠉⠀⠀⠀⠀⠀⠀⠀⠁⢀⠀⠀⠀⢸⣱⣶⣶⡃⠘⠀⠀⠈⠛⠻⠺⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⢤⠀⠀⠙⠉⠀⠀⠀⠀⠀⠀⠖⢳⠧⠦⣠⡀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⡸⣥⠀⠀⠀⣴⡆⢀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠆⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⢀⡀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢂⠘⠀⠀⠐⣿⠇⢠⣠⢀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠠⠀⠀⠸⠇⠆
⠀⠀⠀⠀⠀⠀⠀⠀⢘⡀⠀⡀⠘⠁⣠⣤⣵⣿⠛⠁⣀⣴⣆⣀⡀⠀⠀⠈⠀⡙⠒⣀⡀⠀⠀⠀⠀⠀⢀⢀⠀⠑
⠀⠀⠀⠀⠀⠀⠀⠤⠂⠀⠂⠀⠀⠀⣬⣭⣀⣠⣤⣶⣿⣿⣿⣿⣶⠆⠂⢠⣤⠒⢶⡄⠀⠀⠀⠀⠠⠀⠀⠸⡆⡄
⠀⠀⠀⠀⣀⡔⠉⠀⣠⣤⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠛⠉⠀⢩⣿⡧⠀⠈⠀⠀⠀⠅⠈⠁⢄⢀⠉⠉
⠀⠀⢀⠶⠉⡈⠑⢿⣿⣿⣿⣿⣿⣿⣿⠿⠋⢙⣿⠛⠒⢂⠀⠂⢀⠀⣆⠀⠹⡇⠀⠀⠀⢀⠀⡆⠀⠀⠀⠚⠂⠀
⠀⠀⠀⠠⠀⠀⢠⣿⣿⣿⣿⣿⠿⠋⡡⠴⠚⠉⠀⠀⠠⠄⠄⠄⠀⢥⠍⠇⠀⠅⠀⠀⠀⠠⠀⠇⠀⠀⠄⠀⠀⠀
⠀⠀⠀⠀⠈⠃⢀⣉⣉⣉⣩⠵⠚⠉⠀⠀⠀⠀⢢⡀⣄⡟⠃⢀⠘⠛⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠀⠇⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

        ██╗     ███████╗██████╗  ██████╗ ██╗  ██╗
        ██║     ╚══███╔╝██╔══██╗██╔═══██╗╚██╗██╔╝
        ██║       ███╔╝ ██████╔╝██║   ██║ ╚███╔╝ 
        ██║      ███╔╝  ██╔══██╗██║   ██║ ██╔██╗ 
        ███████╗███████╗██████╔╝╚██████╔╝██╔╝ ██╗
        ╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
  
                LazaroBox.nvim
               Signal over noise.
       ]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "m", desc = "Mason", action = ":Mason" },
					{
						icon = " ",
						key = "h",
						desc = "Harpoon",
						action = ":lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())",
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "recent_files", limit = 5, padding = 1, title = "Recent Files", icon = " " },
				{ section = "projects", limit = 5, padding = 1, title = "Projects", icon = " " },
				{ section = "startup" },
			},
		},
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		rename = { enabled = true },
		image = {
			enabled = true,
			force = true, -- intenta renderizar aunque el terminal le cueste
			doc = {
				enabled = true,
				inline = true, -- Imágenes inline para WezTerm
				float = true,
				max_width = 180,
				max_height = 40,
			},
		},
	},
	keys = {
		-- Top Pickers & Explorer
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>,",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		-- find
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		-- git
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
		},
		-- gh
		{
			"<leader>gi",
			function()
				Snacks.picker.gh_issue()
			end,
			desc = "GitHub Issues (open)",
		},
		{
			"<leader>gI",
			function()
				Snacks.picker.gh_issue({ state = "all" })
			end,
			desc = "GitHub Issues (all)",
		},
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
		{
			"<leader>gP",
			function()
				Snacks.picker.gh_pr({ state = "all" })
			end,
			desc = "GitHub Pull Requests (all)",
		},
		-- Grep
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sB",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
	},
}
