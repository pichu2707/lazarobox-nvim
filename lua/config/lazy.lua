-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Tema antes de lazy.setup: lazarobox vive en colors/ de esta config, asi que
-- no necesita plugin ni `priority = 1000`. Aplicarlo aqui garantiza que los
-- plugins que leen highlights al configurarse (lualine, gitsigns, noice,
-- snacks...) ya lo vean, incluso los que cargan durante el propio setup.
vim.cmd.colorscheme("lazarobox")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- Tema de la UI de lazy cuando instala plugins en el primer arranque
  install = { colorscheme = { "lazarobox" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
  -- Deshabilitar soporte de luarocks para evitar errores
  rocks = {
    enabled = false,
  },
})
