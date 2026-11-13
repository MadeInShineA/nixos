# Fuzzy finder for files, text (grep), buffers, symbols, diagnostics...
{
  flake.modules.nixvim.nvim =
    { pkgs, ... }:
    {
      plugins.telescope = {
        enable = true;
        # Native fzf sorter, faster with fzf-like matching
        extensions.fzf-native.enable = true;

        keymaps = {
          "<leader>f" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>/" = {
            action = "live_grep";
            options.desc = "Grep";
          };
          "<leader>b" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>s" = {
            action = "lsp_document_symbols";
            options.desc = "Symbols";
          };
          "<leader>S" = {
            action = "lsp_dynamic_workspace_symbols";
            options.desc = "Workspace symbols";
          };
          "<leader>d" = {
            action = "diagnostics";
            options.desc = "Diagnostics";
          };
          "<leader>g" = {
            action = "git_status";
            options.desc = "Git status";
          };
          "<leader>?" = {
            action = "keymaps";
            options.desc = "Keymaps";
          };
          # Replace the built-in LSP lists (quickfix) with the picker
          "grr" = {
            action = "lsp_references";
            options.desc = "References";
          };
          "gri" = {
            action = "lsp_implementations";
            options.desc = "Implementations";
          };
        };
      };

      # Used by live_grep and find_files (anything already on PATH wins)
      extraPackagesAfter = [
        pkgs.ripgrep
        pkgs.fd
      ];
    };
}
