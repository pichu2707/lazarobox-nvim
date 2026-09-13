return {
  "tpope/vim-fugitive",
  config = function()
    -- Keymaps básicos de Git
    vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
    vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
    vim.keymap.set("n", "<leader>gca", ":Git commit --amend<CR>", { desc = "Git commit amend" })

    -- Push y Pull
    vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
    vim.keymap.set("n", "<leader>gP", ":Git pull<CR>", { desc = "Git pull" })
    vim.keymap.set("n", "<leader>gf", ":Git fetch<CR>", { desc = "Git fetch" })

    -- Diff y Blame
    vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git diff" })
    vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })

    -- Log
    vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git log" })
    vim.keymap.set("n", "<leader>gL", ":Git log<CR>", { desc = "Git log verbose" })

    -- Branches
    vim.keymap.set("n", "<leader>gB", ":Git branch<CR>", { desc = "Git branches" })
    vim.keymap.set("n", "<leader>gco", ":Git checkout ", { desc = "Git checkout" })

    -- Stage y Add
    vim.keymap.set("n", "<leader>ga", ":Git add %<CR>", { desc = "Git add current file" })
    vim.keymap.set("n", "<leader>gA", ":Git add .<CR>", { desc = "Git add all" })

    -- Stash (kept out of <leader>gs* so "Git status" is not shadowed)
    vim.keymap.set("n", "<leader>gz", ":Git stash<CR>", { desc = "Git stash" })
    vim.keymap.set("n", "<leader>gZ", ":Git stash pop<CR>", { desc = "Git stash pop" })

    -- Merge y Rebase
    vim.keymap.set("n", "<leader>gm", ":Git merge ", { desc = "Git merge" })
    vim.keymap.set("n", "<leader>gr", ":Git rebase ", { desc = "Git rebase" })

    -- Abrir en GitHub/Browser
    vim.keymap.set("n", "<leader>go", ":GBrowse<CR>", { desc = "Open in GitHub" })
    vim.keymap.set("v", "<leader>go", ":GBrowse<CR>", { desc = "Open in GitHub" })
  end,
}
