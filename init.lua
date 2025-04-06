vim.o.tabstop = 4        -- Number of spaces a <Tab> counts for
vim.o.shiftwidth = 4     -- Size of an indent
vim.o.expandtab = true   -- Use spaces instead of tabs
vim.o.clipboard = "unnamedplus"

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

-- Setup lazy.nvim
require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
	{"williamboman/mason.nvim"},
	{"williamboman/mason-lspconfig.nvim"},
	{"neovim/nvim-lspconfig"},
    {
      'stevearc/oil.nvim',
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {},
      -- Optional dependencies
      dependencies = { { "echasnovski/mini.icons", opts = {} } },
      -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
      -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
      lazy = false,
    },
    {'akinsho/toggleterm.nvim', version = "*", config = true}
})

-- Setup mason and lsp plugins
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "rust_analyzer" }, -- Make sure these are valid LSP names from lspconfig
})

require("mason-lspconfig").setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({})
  end,
})

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright" },
})

-- In your Neovim configuration (e.g., init.lua or a dedicated plugin config file)
require("toggleterm").setup({
  -- Dynamically set terminal size:
  --[[size = function(term)
    if term.direction == "horizontal" then
      return 15  -- height for horizontal splits
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4  -- width for vertical splits
    end
  end,]]
  open_mapping = [[<c-\>]],       
  shade_terminals = true,         
  shading_factor = 2,             
  start_in_insert = true,         
  insert_mappings = true,         
  terminal_mappings = true,       -- enable the mapping inside terminal buffers
  persist_size = true,            -- keep the last used size when reopening a terminal
  direction = "horizontal",       -- default orientation; can be changed per terminal
  close_on_exit = true,           -- close terminal window when the process exits
})

-- In your Neovim configuration (e.g., in a file like oil.lua under your plugin config folder)
require("oil").setup({
  -- Let oil.nvim replace netrw as the default file explorer:
  default_file_explorer = true,
  -- Customize the columns to display (e.g., only icons and names):
  columns = { "icon" },
  -- Buffer-specific options (e.g., don’t list oil buffers in the bufferline):
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },
  -- Window options for oil buffers:
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },
  -- File view options:
  view_options = {
    show_hidden = false,         -- Toggle to show hidden files (can be bound to a key)
    natural_order = "fast",      -- Sort file names with a human-friendly ordering
    sort = { {"type", "asc"}, {"name", "asc"} },
  },
  -- Define keymaps for oil buffers:
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",         -- Open the file or directory under the cursor
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },  -- Open in vertical split
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },-- Open in horizontal split
    ["<C-t>"] = { "actions.select", opts = { tab = true } },       -- Open in new tab
    ["<C-p>"] = "actions.preview",         -- Preview the file under the cursor
    ["-"] = { "actions.parent", mode = "n" },-- Go up one directory level
    ["_"] = { "actions.open_cwd", mode = "n" },-- Open oil at the current working directory
    ["gx"] = "actions.open_external",      -- Open file with external program
    ["gs"] = { "actions.change_sort", mode = "n" }, -- Change sort order
  },
  -- Use the default keymaps if you don’t need custom ones:
  use_default_keymaps = true,
})

vim.cmd[[colorscheme tokyonight-moon]]
