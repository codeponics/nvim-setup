vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.clipboard = "unnamedplus"

vim.o.scrolloff = 10
vim.o.undofile = true
vim.o.wrap = false

vim.wo.number = true

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            {
                {"Failed to clone lazy.nvim:\n", "ErrorMsg"},
                {out, "WarningMsg"},
                {"\nPress any key to exit..."}
            },
            true,
            {}
        )
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--lsps
local lsps = {
  lua_ls = {},
  pyright = {
    settings = {
      python = {
        analysis = { typeCheckingMode = "off" },
        pythonPath = vim.fn.executable("python3") == 1 and
            vim.fn.exepath("python3") or
            vim.fn.exepath("python")
      }
    }
  },
  markdown_oxide = {}
}
if vim.fn.has("win32") == 1 then
  lsps.omnisharp = {}
end

-- Setup lazy.nvim
require("lazy").setup(
    {
        {
            "folke/tokyonight.nvim",
            lazy = false,
            priority = 1000,
            opts = {}
        },
        {"williamboman/mason.nvim"},
        {"williamboman/mason-lspconfig.nvim"},
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
                {"saghen/blink.cmp", version = "*", opts = {}}
            },
            config = function()
            local cmp = require("blink.cmp").get_lsp_capabilities()
            require("mason").setup()
            require("mason-lspconfig").setup({
              ensure_installed = vim.tbl_keys(lsps),
              handlers = {
                function(name)
                  local conf = lsps[name] or {}
                  conf.capabilities = cmp
                  require("lspconfig")[name].setup(conf)
                end
              }
            })
          end
        },
        {"nvim-tree/nvim-web-devicons"},
        {"nvim-tree/nvim-tree.lua",
          config = function()
            require("nvim-tree").setup({})
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
          end
        },
        {"akinsho/toggleterm.nvim", version = "*", config = true},
        {"nvim-lualine/lualine.nvim", opts = {}},
        { 'mcauley-penney/visual-whitespace.nvim', config = true},
        { "MeanderingProgrammer/render-markdown.nvim", opts = {} },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            event = {"BufReadPost", "BufNewFile"},
            config = function()
                require("nvim-treesitter.configs").setup(
                    {
                        auto_install = true,
                        highlight = {enable = true},
                        indent = {enable = true}
                    }
                )
            end
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = {"nvim-lua/plenary.nvim"}
        }
    }
)

require("mason").setup()

require("mason-lspconfig").setup(
    {
        ensure_installed = {"lua_ls", "pyright", "omnisharp" }
    }
)

require("mason-lspconfig").setup_handlers(
    {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end
    }
)

require("toggleterm").setup(
    {
        open_mapping = [[<c-\>]],
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", [[<C-\><C-n>]], {noremap = true, silent = true})
        end
    }
)

vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- or "■", "▶"
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader><leader>", builtin.live_grep, {})

vim.cmd [[colorscheme tokyonight-moon]]

-- Indent and reselect visual selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
