-- Silenciar warning de lspconfig mientras llega nvim 0.11
vim.deprecate = function() end

require("config/options")
require("config/keymaps")
require("config.lazy")
require("config.media-autocmds")
require("config.version").setup()
vim.opt.clipboard = "unnamedplus"

-- Forzar uso de xclip en X11
if vim.fn.has('unix') == 1 and vim.fn.executable('xclip') == 1 then
  vim.g.clipboard = {
    name = 'xclip-system',
    copy = {
      ['+'] = 'xclip -sel clip',
      ['*'] = 'xclip -sel prim',
    },
    paste = {
      ['+'] = 'xclip -sel clip -o',
      ['*'] = 'xclip -sel prim -o',
    },
    cache_enabled = 0,
  }
end
