# Theme, status line, buffer tabs and other visual helpers
{
  flake.modules.nixvim.nvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
      };
    };

    plugins = {
      # File type icons, used by the tree, statusline, bufferline, picker
      web-devicons.enable = true;

      # Status line at the bottom (mode, git branch, diagnostics, position)
      lualine = {
        enable = true;
        settings.options = {
          theme = "catppuccin-mocha";
          globalstatus = true;
        };
      };

      # Open buffers shown as tabs at the top
      bufferline = {
        enable = true;
        settings.options.offsets = [
          {
            filetype = "neo-tree";
            text = "Files";
            separator = true;
          }
        ];
      };

      # Popup listing available keybindings after pressing a prefix (e.g. Space)
      which-key = {
        enable = true;
      };

      # Vertical indentation guides
      indent-blankline.enable = true;

      # LSP progress messages in the bottom-right corner
      fidget.enable = true;

      # Highlights and searches TODO / FIXME / NOTE comments
      todo-comments.enable = true;
    };
  };
}
