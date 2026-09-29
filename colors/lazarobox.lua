-- Punto de entrada de `:colorscheme lazarobox`; la logica vive en lua/lazarobox/theme.lua
--
-- Fondo solido por defecto: asi el terminal decide cuanto se ve su fondo detras
-- de nvim (en WezTerm, text_background_opacity) sin que distraiga al programar.
-- vim.g.lazarobox_transparent = true lo deja transparente del todo.
require("lazarobox.theme").load({ transparent = vim.g.lazarobox_transparent == true })
