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

					local run_cargo = function(command)
						local ok, terminal = pcall(require, "toggleterm.terminal")

						if ok then
							terminal.Terminal:new({
								cmd = command,
								direction = "float",
								close_on_exit = false,
							}):toggle()
							return
						end

						vim.cmd("botright 15split")
						vim.cmd("terminal " .. command)
					end

					map("<leader>Rd", vim.diagnostic.open_float, "Rust: show diagnostic")
					map("<leader>Rj", vim.diagnostic.goto_next, "Rust: next diagnostic")
					map("<leader>Rk", vim.diagnostic.goto_prev, "Rust: previous diagnostic")
					map("<leader>Rq", vim.diagnostic.setloclist, "Rust: list diagnostics")
					map("<leader>Rc", "<cmd>RustLsp flyCheck run<cr>", "Rust: run flyCheck")
					map("<leader>Rr", "<cmd>RustLsp runnables<cr>", "Rust: runnables")
					map("<leader>RR", "<cmd>RustLsp! runnables<cr>", "Rust: re-run last runnable")
					map("<leader>Rt", "<cmd>RustLsp testables<cr>", "Rust: testables")
					map("<leader>RT", "<cmd>RustLsp! testables<cr>", "Rust: re-run last testable")
					map("<leader>Rg", "<cmd>RustLsp debuggables<cr>", "Rust: debuggables")
					map("<leader>RG", "<cmd>RustLsp! debuggables<cr>", "Rust: re-run last debuggable")
					map("<leader>Rb", function()
						run_cargo("cargo build")
					end, "Rust: cargo build")
					map("<leader>Rx", function()
						run_cargo("cargo run")
					end, "Rust: cargo run")
					map("<leader>Rs", function()
						run_cargo("cargo test")
					end, "Rust: cargo test")
					map("<leader>RC", function()
						run_cargo("cargo clippy")
					end, "Rust: cargo clippy")
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
