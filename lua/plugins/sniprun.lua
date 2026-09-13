return{
  'michaelb/sniprun',
  branch = 'master',
  build = 'sh install.sh',
  config = function()
    require('sniprun').setup({
      selected_interpreters = {
        'JS_original',     -- JavaScript (Node.js)
        'Python3_original', -- Python
        'TypeScript_original' -- TypeScript
      },
      repl_enable = {
        'JS_original',
        'Python3_original',
        'TypeScript_original'
      },
      repl_disable = {},
      
      -- Configuración de display
      display = {
        "VirtualText",               -- display results as virtual text inline
        "TempFloatingWindow",     -- deshabilitado para que errores sean menos molestos
      },

      live_display = { "VirtualText" }, -- display mode used in live_mode

      display_options = {
        terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
        terminal_line_number = false, -- whether show line number in terminal window
        terminal_signcolumn = false,  -- whether show signcolumn in terminal window
        terminal_persistence = true,  -- always keep the terminal window even if no output
        terminal_width = 45,          -- change the terminal display option width (if vertical)
        terminal_height = 20,         -- change the terminal display option height (if horizontal)
        notification_timeout = 2     -- timeout reducido para errores
      },

      show_no_output = {
        "VirtualText",  -- Mostrar solo en texto virtual, no en ventana flotante
      },

      -- shortcuts to quickly run your code
      inline_messages = 1,    -- solo 1 línea de mensaje inline
      borders = 'single',        -- display borders around floating windows borders = { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" }
    })

    -- Keymaps removed in favour of the <leader>x runners (see keymaps.lua).
    -- The :SnipRun* commands remain available.
  end,
}
