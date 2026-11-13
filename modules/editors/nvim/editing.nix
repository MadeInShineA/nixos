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

      # Close buffers without closing the window they are shown in
      mini-bufremove.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>x";
        action.__raw = "function() MiniBufremove.delete() end";
        options.desc = "Close buffer";
      }
    ];
  };
}
