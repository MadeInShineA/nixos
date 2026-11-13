# Floating terminal running nushell (falls back to the default shell where nu isn't installed)
{
  flake.modules.nixvim.nvim = {
    plugins.toggleterm = {
      enable = true;
      settings = {
        shell.__raw = ''vim.fn.executable("nu") == 1 and "nu" or vim.o.shell'';
        direction = "float";
      };
    };

    keymaps = [
      {
        # Open / close the terminal (also works while typing in it)
        mode = [
          "n"
          "t"
        ];
        key = "<C-\\>";
        action = "<cmd>ToggleTerm<cr>";
        options.desc = "Terminal";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Terminal normal mode";
      }
    ];
  };
}
