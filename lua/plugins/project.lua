return {
  "ahmedkhalf/project.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("project_nvim").setup({
      manual_mode = false,
      detection_methods = { "pattern" },
      patterns = {
        ".git",
        ".projectroot",
        "pyproject.toml",
        "setup.py",
        "package.json",
        "tsconfig.json",
      },
      scope_chdir = "global",
    })

    vim.opt.autochdir = false

    -- ESTE es el autocmd (sustituye al que tuvieras antes)
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      callback = function()
        -- Ignorar buffers que no son archivos reales
        if vim.bo.buftype ~= "" then return end
        if vim.fn.expand("%:p") == "" then return end

        -- Diferir: cambiar cwd de forma sincrona aqui interfiere con
        -- la cascada de WinEnter/BufEnter que usan pickers como
        -- snacks.explorer al abrir un fichero (ver "Invalid 'name'").
        vim.schedule(function()
          local ok, project = pcall(require, "project_nvim.project")
          if not ok then
            vim.notify("project.nvim not available", vim.log.levels.WARN)
            return
          end

          local root = project.get_project_root()
          if not root or root == "" then
            return
          end

          local cwd = vim.fn.getcwd()
          if cwd ~= root then
            vim.cmd("silent! lcd " .. vim.fn.fnameescape(root))
            vim.notify("cd -> " .. root, vim.log.levels.INFO)
          end
        end)
      end,
    })
  end,
}

