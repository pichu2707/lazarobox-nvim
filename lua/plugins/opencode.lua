return {
	"sudo-tee/opencode.nvim",
	-- El comando real es "Opencode", no "OpenCode". Los cuatro nombres que habia
	-- aqui (OpenCode/OpenCodeChat/OpenCodeToggle/OpenCodeSend) no existen en el
	-- plugin, asi que ni cmd ni keys llegaban a cargarlo nunca.
	cmd = { "Opencode" },
	keys = {
		-- Stub de lazy: al pulsarlo carga el plugin, que entonces registra su
		-- propio set <leader>O* (incluida esta tecla) desde keymap_prefix.
		{ "<leader>Og", "<cmd>Opencode<cr>", desc = "Toggle OpenCode" },
	},
	opts = {
		-- Oil se queda con <leader>o. Cambiar el prefijo reubica de una vez los
		-- ~33 mapeos por defecto del plugin (config.update_keymap_prefix), en
		-- lugar de mover tres a mano y dejar el resto encima de Oil.
		keymap_prefix = "<leader>O",
		keymap = {
			output_window = {
				-- <tab> por defecto llama toggle_pane que rompe con winfixbuf (E1513)
				-- Se mueve a <C-Tab> para no colisionar con navegación de buffers
				['<tab>'] = false,
				['<C-Tab>'] = { 'toggle_pane', mode = { 'n' }, desc = 'Toggle input/output panes' },
			},
			input_window = {
				['<tab>'] = false,
				['<C-Tab>'] = { 'toggle_pane', mode = { 'n' }, desc = 'Toggle input/output panes', defer_to_completion = true },
			},
		},
	},
}
