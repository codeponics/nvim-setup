-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.clipboard = "unnamedplus"
vim.o.scrolloff = 10
vim.o.undofile = true
vim.o.wrap = false

vim.o.ignorecase = true
vim.o.smartcase = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.o.colorcolumn = "80"
    vim.o.textwidth = 80
  end
})

vim.wo.number = true
--vim.wo.relativenumber = true

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local save_pos = vim.fn.winsaveview()
    -- remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save_pos)
  end
})

-- mappings

local ndel = function(lhs)
  vim.keymap.del("n", lhs)
end

ndel("grn")
ndel("gra")
ndel("grr")
ndel("gri")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local nmapb = function(lhs, cmd)
      vim.keymap.set("n", lhs, cmd, { buffer = ev.buf })
    end
    nmapb("gd", vim.lsp.buf.definition)
    nmapb("gr", vim.lsp.buf.references)
    nmapb("cr", vim.lsp.buf.rename)
    nmapb("cf", vim.lsp.buf.format)
    nmapb("ca", vim.lsp.buf.code_action)
  end
})

-- lsps/diagnostics

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

vim.diagnostic.config({
  virtual_lines = { current_line = true },
  virtual_text = true
})

-- packages

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-tree/nvim-web-devicons" },
  { "xiyaowong/virtcolumn.nvim" },
  { "windwp/nvim-autopairs",                     opts = {} },
  { "lewis6991/gitsigns.nvim",                   opts = {} },
  { "nvim-lualine/lualine.nvim",                 opts = {} },
  { "MeanderingProgrammer/render-markdown.nvim", opts = {} },
  { "mcauley-penney/visual-whitespace.nvim",     opts = {} },
  {
	  "catppuccin/nvim",
	  name = "catppuccin",
	  priority = 1000,
	  config = function()
	    require("catppuccin").setup({
	      flavour = "mocha",
	      integrations = {
		ts_rainbow = true,
	      },
	      color_overrides = {
		mocha = {
		  text = "#F4CDE9",
		  subtext1 = "#DEBAD4",
		  subtext0 = "#C8A6BE",
		  overlay2 = "#B293A8",
		  overlay1 = "#9C7F92",
		  overlay0 = "#866C7D",
		  surface2 = "#705867",
		  surface1 = "#5A4551",
		  surface0 = "#44313B",
		  base = "#352939",
		  mantle = "#211924",
		  crust = "#1a1016",
		},
	      },
	    })

	    vim.cmd.colorscheme("catppuccin")
	  end
	},
  {"nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end
  },
  {"akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
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
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
        end
      })
    end
  },
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    config = function()
      require("lsp-lens").setup({
        --[[sections = {
          references = false,
          git_authors = false
        }]]
      })
    end,
    setup = function()
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
    end
  },
  {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = {"nvim-lua/plenary.nvim"}
  },
  { "lervag/vimtex" },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = {
        show_start = false,
        show_end = false
      }
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = {
          enable = true,
          disable = { "markdown" }
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "saghen/blink.cmp", version = "*", opts = {} },
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
  }
}, { rocks = { enabled = false } })

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader><leader>", builtin.live_grep, {})
vim.keymap.set("n", "<leader>f", builtin.find_files, {})

-- Indent and reselect visual selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- vimtex
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_view_enabled = 0

vim.opt.conceallevel = 2
vim.g.tex_conceal = 'abdmg'

vim.g.vimtex_view_method = 'sioyek'
--vim.g.vimtex_view_sioyek_exe = "C:\\Program Files\\sioyek\\sioyek-release-windows\\sioyek.exe"
vim.g.vimtex_view_sioyek_exe = "C:\\Users\\steve\\Downloads\\sioyek-release-windows\\sioyek-release-windows\\sioyek.exe"

-- Disable help
vim.keymap.set('n', '<F1>', '<nop>', { noremap = true, silent = true })
vim.keymap.set('i', '<F1>', '<nop>', { noremap = true, silent = true })

-- Close when jumping
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
  end,
})
