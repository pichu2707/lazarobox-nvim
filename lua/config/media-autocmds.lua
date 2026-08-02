-- Autocomandos para abrir PDFs y videos con aplicaciones externas
-- No requiere plugins adicionales

-- Función para abrir PDFs
local function open_pdf()
  local file = vim.fn.expand("%:p")
  if vim.fn.filereadable(file) == 1 then
    -- Intentar abrir con zathura, luego evince, luego xdg-open
    local viewers = { "zathura", "evince", "okular", "xdg-open" }
    for _, viewer in ipairs(viewers) do
      if vim.fn.executable(viewer) == 1 then
        vim.fn.jobstart({ viewer, file }, { detach = true })
        print("Abriendo PDF con " .. viewer .. ": " .. vim.fn.fnamemodify(file, ":t"))
        return
      end
    end
    print("No se encontró visor de PDF. Instala: sudo apt install zathura")
  end
end

-- Función para abrir videos
local function open_video()
  local file = vim.fn.expand("%:p")
  if vim.fn.filereadable(file) == 1 then
    -- Intentar abrir con mpv, luego vlc, luego xdg-open
    local players = { "mpv", "vlc", "xdg-open" }
    for _, player in ipairs(players) do
      if vim.fn.executable(player) == 1 then
        vim.fn.jobstart({ player, file }, { detach = true })
        print("Reproduciendo video con " .. player .. ": " .. vim.fn.fnamemodify(file, ":t"))
        return
      end
    end
    print("No se encontró reproductor de video. Instala: sudo apt install mpv")
  end
end

-- Autocomandos para abrir automáticamente
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.pdf" },
  callback = function()
    vim.defer_fn(function()
      open_pdf()
      -- Cerrar el buffer después de abrir el visor externo
      vim.cmd("bdelete")
    end, 100)
  end,
  desc = "Abrir PDFs con visor externo"
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv", "*.flv", "*.webm", "*.m4v" },
  callback = function()
    vim.defer_fn(function()
      open_video()
      -- Cerrar el buffer después de abrir el reproductor
      vim.cmd("bdelete")
    end, 100)
  end,
  desc = "Abrir videos con reproductor externo"
})

-- Comandos manuales
vim.api.nvim_create_user_command("OpenPDF", open_pdf, { desc = "Abrir PDF con visor externo" })
vim.api.nvim_create_user_command("OpenVideo", open_video, { desc = "Abrir video con reproductor externo" })

-- Keymaps opcionales
vim.keymap.set("n", "<leader>mp", open_pdf, { desc = "Media: Open PDF" })
vim.keymap.set("n", "<leader>mv", open_video, { desc = "Media: Open video" })
