return {
	-- Core DAP
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- DAP UI
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				config = function()
					local dap = require("dap")
					local dapui = require("dapui")

					dapui.setup({
						icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
						mappings = {
							expand = { "<CR>", "<2-LeftMouse>" },
							open = "o",
							remove = "d",
							edit = "e",
							repl = "r",
							toggle = "t",
						},
						layouts = {
							{
								elements = {
									{ id = "scopes", size = 0.25 },
									{ id = "breakpoints", size = 0.25 },
									{ id = "stacks", size = 0.25 },
									{ id = "watches", size = 0.25 },
								},
								size = 40,
								position = "left",
							},
							{
								elements = {
									{ id = "repl", size = 0.5 },
									{ id = "console", size = 0.5 },
								},
								size = 10,
								position = "bottom",
							},
						},
						floating = {
							max_height = nil,
							max_width = nil,
							border = "rounded",
							mappings = {
								close = { "q", "<Esc>" },
							},
						},
					})

					-- Auto open/close UI
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open()
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close()
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close()
					end
				end,
			},

			-- Virtual text for variables
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {
					enabled = true,
					enabled_commands = true,
					highlight_changed_variables = true,
					highlight_new_as_changed = false,
					show_stop_reason = true,
					commented = false,
					only_first_definition = true,
					all_references = false,
					virt_text_pos = "eol",
				},
			},

			-- Mason DAP integration
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = { "williamboman/mason.nvim" },
				opts = {
					ensure_installed = { "python", "js", "codelldb" },
					automatic_installation = false,
					handlers = {},
				},
			},
		},
		config = function()
			local dap = require("dap")

			-- Breakpoint icons
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignOk", linehl = "DapStoppedLine", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

			-- Highlight for stopped line
			vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2d3f2d" })

			-- Python adapter
			dap.adapters.python = function(cb, config)
				if config.request == "attach" then
					local port = (config.connect or config).port
					local host = (config.connect or config).host or "127.0.0.1"
					cb({
						type = "server",
						port = assert(port, "`connect.port` is required for a python `attach` configuration"),
						host = host,
						options = {
							source_filetype = "python",
						},
					})
				else
					cb({
						type = "executable",
						command = "debugpy-adapter",
						options = {
							source_filetype = "python",
						},
					})
				end
			end

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
						if vim.fn.executable(venv_path) == 1 then
							return venv_path
						end
						return "python3"
					end,
				},
				{
					type = "python",
					request = "launch",
					name = "Launch file with arguments",
					program = "${file}",
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " ")
					end,
					pythonPath = function()
						local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
						if vim.fn.executable(venv_path) == 1 then
							return venv_path
						end
						return "python3"
					end,
				},
			}

			-- JavaScript/TypeScript adapter (using js-debug-adapter)
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "js-debug-adapter",
					args = { "${port}" },
				},
			}

			dap.configurations.javascript = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
			}

			dap.configurations.typescript = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					runtimeExecutable = "ts-node",
					sourceMaps = true,
					protocol = "inspector",
					skipFiles = { "<node_internals>/**", "node_modules/**" },
				},
			}

			-- Rust/C/C++ adapter (using codelldb)
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = "codelldb",
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.rust = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			dap.configurations.c = dap.configurations.rust
			dap.configurations.cpp = dap.configurations.rust
		end,
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "DAP: Conditional breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "DAP: Continue" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "DAP: Step into" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "DAP: Step over" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "DAP: Step out" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: Toggle REPL" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "DAP: Run last" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "DAP: Toggle UI" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "DAP: Terminate" },
			{ "<leader>de", function() require("dapui").eval() end, desc = "DAP: Eval", mode = { "n", "v" } },
			{ "<leader>df", function() require("dapui").float_element() end, desc = "DAP: Float element" },
		},
	},
}
