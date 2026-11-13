# Jump anywhere on screen: `s` + 1-2 chars, then the label shown at the target
{
  flake.modules.nixvim.nvim = {
    plugins.flash.enable = true;

    keymaps = [
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = "function() require('flash').jump() end";
        options.desc = "Flash jump";
      }
      {
        # Select a treesitter node (expression, block, function...) by label
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = "function() require('flash').treesitter() end";
        options.desc = "Flash treesitter";
      }
      {
        # Operate somewhere else without moving, e.g. `yr` + jump + `iw`
        mode = "o";
        key = "r";
        action.__raw = "function() require('flash').remote() end";
        options.desc = "Remote flash";
      }
    ];
  };
}
