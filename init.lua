-- Silenciar warning de lspconfig mientras llega nvim 0.11
vim.deprecate = function() end

require("config/options")
require("config/keymaps")
require("config.lazy")
require("config.media-autocmds")
require("config.version").setup()
