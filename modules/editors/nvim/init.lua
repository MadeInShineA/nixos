-- Options -------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.showmode = false
o.foldlevelstart = 99

-- C++: 2 spaces (same as zed)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c", "cuda" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-- Theme ---------------------------------------------------------------
require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
vim.cmd.colorscheme("catppuccin-mocha")

-- UI ------------------------------------------------------------------
require("lualine").setup({ options = { theme = "catppuccin-mocha", globalstatus = true } })
require("bufferline").setup({
  options = { offsets = { { filetype = "neo-tree", text = "Files", separator = true } } },
})
require("which-key").setup({})
require("ibl").setup({})
require("fidget").setup({})
require("todo-comments").setup({})
require("nvim-autopairs").setup({})
require("gitsigns").setup({})
require("mini.bufremove").setup()

-- File tree on the left (like zed's project panel)
require("neo-tree").setup({
  close_if_last_window = true,
  window = { position = "left", width = 32 },
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = { visible = true, hide_dotfiles = false },
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        -- yazi-like navigation
        ["l"] = "open", -- expand folder / open file
        ["h"] = "close_node", -- collapse folder, or jump to and collapse parent
        ["L"] = "set_root", -- cd into folder
        ["H"] = "navigate_up", -- cd to parent directory
        ["."] = "toggle_hidden",
      },
    },
  },
})

-- Picker
local telescope = require("telescope")
telescope.setup({})
telescope.load_extension("fzf")

-- Terminal running nushell (falls back to the default shell where nu isn't installed)
require("toggleterm").setup({
  shell = vim.fn.executable("nu") == 1 and "nu" or vim.o.shell,
  direction = "float",
})

-- Treesitter (grammars from nix) ---------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- Completion ----------------------------------------------------------
require("blink.cmp").setup({
  keymap = { preset = "default" },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
})

-- Diagnostics: inline, warnings and errors only (like zed) ------------
vim.diagnostic.config({
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
  severity_sort = true,
  float = { border = "rounded" },
})

-- LSP -----------------------------------------------------------------
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

vim.lsp.config("rust_analyzer", {
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.config("nixd", {
  settings = { nixd = { formatting = { command = { "nixfmt" } } } },
})

local servers = {
  "nixd",          -- nix
  "tinymist",      -- typst
  "codebook",      -- spell checking
  "taplo",         -- toml
  "vue_ls",        -- vue
  "vtsls",         -- typescript (needed by vue_ls)
  "intelephense",  -- php
  "nushell",       -- nu
  "dockerls",      -- dockerfile
  "metals",        -- scala
  "hls",           -- haskell
  "r_language_server", -- r
  "clangd",        -- c / cpp / cuda
  "gleam",         -- gleam
  "jdtls",         -- java
  "gopls",         -- go
  "rust_analyzer", -- rust
  "ruff",          -- python (lint + format)
  "basedpyright",  -- python (types)
  "pyright",       -- python (types, if basedpyright isn't available)
  "lua_ls",        -- lua
  "marksman",      -- markdown
}

-- Only enable servers whose binary is available (provided by project flakes)
for _, name in ipairs(servers) do
  local cfg = vim.lsp.config[name]
  local cmd = cfg and cfg.cmd
  if type(cmd) == "function" or (type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1) then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- Format on save ------------------------------------------------------
require("conform").setup({
  formatters_by_ft = {
    nix = { "nixfmt" },
  },
  format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
})

-- Keymaps -------------------------------------------------------------
local map = vim.keymap.set
local tb = require("telescope.builtin")

map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File tree" })
map("n", "<leader>f", tb.find_files, { desc = "Find files" })
map("n", "<leader>/", tb.live_grep, { desc = "Grep" })
map("n", "<leader>b", tb.buffers, { desc = "Buffers" })
map("n", "<leader>s", tb.lsp_document_symbols, { desc = "Symbols" })
map("n", "<leader>S", tb.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>d", tb.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>g", tb.git_status, { desc = "Git status" })
map("n", "<leader>?", tb.keymaps, { desc = "Keymaps" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto type definition" })
map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename" })
map({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>k", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>h", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Terminal" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<leader>x", function() MiniBufremove.delete() end, { desc = "Close buffer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
