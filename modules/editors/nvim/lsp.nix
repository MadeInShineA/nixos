# Language servers. They are NOT installed here: they come from project
# flakes (direnv), and a server is only enabled when its binary is on PATH.
{ lib, ... }:
let
  servers = [
    "nixd" # nix
    "tinymist" # typst
    "codebook" # spell checking
    "taplo" # toml
    "vue_ls" # vue
    "vtsls" # typescript (needed by vue_ls)
    "intelephense" # php
    "nushell" # nu
    "dockerls" # dockerfile
    "metals" # scala
    "hls" # haskell
    "r_language_server" # r
    "clangd" # c / cpp / cuda
    "gleam" # gleam
    "jdtls" # java
    "gopls" # go
    "rust_analyzer" # rust
    "ruff" # python (lint + format)
    "basedpyright" # python (types)
    "lua_ls" # lua
    "marksman" # markdown
  ];
in
{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    {
      # Default server configs (cmd, filetypes, root markers)
      plugins.lspconfig.enable = true;

      lsp = {
        inlayHints.enable = true;

        # Configure every server without installing or starting it ...
        servers =
          lib.recursiveUpdate
            (lib.genAttrs servers (_: {
              enable = true;
              package = null;
              activate = false;
            }))
            {
              rust_analyzer.config.settings.rust-analyzer.check.command = "clippy";
              nixd.config.settings.nixd.formatting.command = [ "nixfmt" ];
            };

        # Also built in (Neovim 0.11+): grn rename, gra code action,
        # grr references, gri implementation, grt type definition,
        # gO document symbols, K hover, <C-s> signature help (insert mode)
        keymaps = [
          {
            key = "gd";
            lspBufAction = "definition";
            options.desc = "Goto definition";
          }
          {
            key = "gy";
            lspBufAction = "type_definition";
            options.desc = "Goto type definition";
          }
          {
            key = "<leader>r";
            lspBufAction = "rename";
            options.desc = "Rename";
          }
          {
            mode = [
              "n"
              "v"
            ];
            key = "<leader>a";
            lspBufAction = "code_action";
            options.desc = "Code action";
          }
        ];
      };

      # ... then start only the ones whose binary is available
      lsp.luaConfig.post = ''
        for _, name in ipairs(${lib.nixvim.toLuaObject servers}) do
          local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
          if type(cmd) == "function" or (type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1) then
            vim.lsp.enable(name)
          end
        end
      '';

      keymaps = [
        {
          mode = "n";
          key = "<leader>h";
          action.__raw = ''
            function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end
          '';
          options.desc = "Toggle inlay hints";
        }
      ];
    };
}
