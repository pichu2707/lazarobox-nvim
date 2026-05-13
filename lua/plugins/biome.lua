return {
  -- Plugin separado para configuración específica de Biome
  "williamboman/mason.nvim", -- Solo depende de mason, no duplica lspconfig
  dependencies = { 'williamboman/mason-lspconfig.nvim' },
  config = function()
    -- Configuración específica para Biome LSP
    local lspconfig = require('lspconfig')
    
    -- Configurar Biome como LSP server
    lspconfig.biome.setup({
      on_attach = function(client, bufnr)
        -- Habilitar formato con Biome LSP
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_buf_set_option(bufnr, 'formatexpr', "v:lua.vim.lsp.formatexpr()")
          
          -- Keymap específico para formato con Biome LSP
          vim.keymap.set('n', '<leader>bf', function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = bufnr, desc = 'Format with Biome LSP' })
        end

        -- Keymap para organizar imports
        vim.keymap.set('n', '<leader>bo', function()
          vim.lsp.buf.code_action({
            filter = function(action)
              return action.kind == 'source.organizeImports'
            end,
            apply = true,
          })
        end, { buffer = bufnr, desc = 'Organize imports with Biome' })

        -- Keymap para fix all
        vim.keymap.set('n', '<leader>bx', function()
          vim.lsp.buf.code_action({
            filter = function(action)
              return action.kind == 'source.fixAll'
            end,
            apply = true,
          })
        end, { buffer = bufnr, desc = 'Fix all with Biome' })
      end,
      
      -- Solo activar Biome si existe configuración de Biome
      root_dir = function(fname)
        return lspconfig.util.root_pattern('biome.json', 'biome.jsonc')(fname)
      end,
      
      settings = {
        biome = {
          -- Configuraciones adicionales de Biome
          linter = {
            enabled = true,
          },
          formatter = {
            enabled = true,
            formatOnSave = {
              enabled = false, -- Lo manejamos con conform.nvim
            },
          },
          organizeImports = {
            enabled = true,
          },
        },
      },
    })

    -- Comando para crear configuración básica de Biome
    vim.api.nvim_create_user_command('BiomeInit', function()
      local biome_config = {
        ['$schema'] = 'https://biomejs.dev/schemas/1.4.1/schema.json',
        organizeImports = { enabled = true },
        linter = {
          enabled = true,
          rules = {
            recommended = true,
          },
        },
        formatter = {
          enabled = true,
          indentStyle = 'tab',
          indentWidth = 2,
        },
        javascript = {
          formatter = {
            quoteStyle = 'single',
            semicolons = 'asNeeded',
          },
        },
        json = {
          formatter = {
            indentStyle = 'space',
          },
        },
      }
      
      local config_content = vim.json.encode(biome_config, { indent = 2 })
      vim.fn.writefile(vim.split(config_content, '\n'), 'biome.json')
      print('Created biome.json configuration file')
    end, { desc = 'Create basic biome.json configuration' })
  end,
}