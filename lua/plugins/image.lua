return {
	"3rd/image.nvim",
	-- Requiere: WezTerm y ImageMagick (`sudo apt install imagemagick`)
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		backend = "kitty", -- WezTerm soporta protocolo Kitty
		processor = "magick_cli", -- Usa ImageMagick CLI en lugar de luarocks magick
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki" },
			},
			neorg = {
				enabled = false, -- Deshabilitado temporalmente por problemas con norg_meta parser
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "norg" },
			},
			html = {
				enabled = true, -- Habilitado para proyectos web
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = true,
				filetypes = { "html", "xhtml", "astro", "vue", "svelte" },
			},
			css = {
				enabled = true, -- Habilitado para ver imágenes de fondo
			},
		},
		max_width = nil,
		max_height = nil,
		max_width_window_percentage = 80,
		max_height_window_percentage = 50,
		window_overlap_clear_enabled = true, -- Limpia imágenes cuando ventanas se solapan
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		editor_only_render_when_focused = false,
		tmux_show_only_in_active_window = false,
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.bmp", "*.ico", "*.svg" },
	},
}
