# Format on save, with per-filetype formatters and LSP fallback
# :FormatToggle disables/enables it globally, :FormatToggle! for the current buffer only
{
  flake.modules.nixvim.nvim =
    { pkgs, ... }:
    {
      plugins.conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft.nix = [ "nixfmt" ];
          format_on_save.__raw = ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return { timeout_ms = 1000, lsp_format = "fallback" }
            end
          '';
        };
      };

      userCommands.FormatToggle = {
        bang = true;
        desc = "Toggle format on save (! = buffer only)";
        command.__raw = ''
          function(args)
            if args.bang then
              vim.b.disable_autoformat = not vim.b.disable_autoformat
            else
              vim.g.disable_autoformat = not vim.g.disable_autoformat
            end
          end
        '';
      };

      # Used by conform and nixd (anything already on PATH wins)
      extraPackagesAfter = [ pkgs.nixfmt ];
    };
}
