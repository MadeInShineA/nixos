# Syntax, brackets and buffer handling
{
  flake.modules.nixvim.nvim = {
    plugins = {
      # Treesitter with every grammar prebuilt (highlighting, indent, folding)
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
      };

      # Automatically inserts the closing bracket / quote
      nvim-autopairs.enable = true;

      # Add / change / delete surroundings: ysiw" cs"' ds"
      # Visual mode uses gs / gS since S is taken by flash
      nvim-surround.enable = true;

      # Close buffers without closing the window they are shown in
      mini-bufremove.enable = true;
    };

    # Drop nvim-surround's visual S / gS (S is flash), rebound to gs / gS below
    globals.nvim_surround_no_visual_mappings = true;

    keymaps = [
      {
        mode = "x";
        key = "gs";
        action = "<Plug>(nvim-surround-visual)";
        options.desc = "Surround selection";
      }
      {
        mode = "x";
        key = "gS";
        action = "<Plug>(nvim-surround-visual-line)";
        options.desc = "Surround selection on new lines";
      }
      {
        mode = "n";
        key = "<leader>x";
        action.__raw = "function() MiniBufremove.delete() end";
        options.desc = "Close buffer";
      }
    ];
  };
}
