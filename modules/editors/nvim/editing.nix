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

      # Pin the enclosing function / class / block header at the top while scrolling
      treesitter-context = {
        enable = true;
        settings.max_lines = 3;
      };

      # Detect tabs vs spaces and indent width per file
      guess-indent.enable = true;

      # Automatically inserts the closing bracket / quote
      nvim-autopairs.enable = true;

      # Add / change / delete surroundings: ysiw" cs"' ds"
      # Visual mode uses gs / gS since S is taken by flash
      nvim-surround.enable = true;

      # Close buffers without closing the window they are shown in
      mini-bufremove.enable = true;

      # Move lines / selections with <M-hjkl> (vertical moves reindent)
      mini-move.enable = true;
    };

    # Drop nvim-surround's visual S / gS (S is flash), rebound to gs / gS below
    globals.nvim_surround_no_visual_mappings = true;

    # Briefly flash the yanked region
    autoCmd = [
      {
        event = "TextYankPost";
        callback.__raw = ''
          function()
            vim.hl.on_yank({ timeout = 200 })
          end
        '';
      }
    ];

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
