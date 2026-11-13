# Indentation while typing (Tab, >>, auto-indent): spaces, 4 wide by default
{
  flake.modules.nixvim.nvim = {
    opts = {
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
    };

    # 2-space languages (C++ same as zed; nix to match nixfmt)
    autoCmd = [
      {
        event = "FileType";
        pattern = [
          "cpp"
          "c"
          "cuda"
          "nix"
        ];
        callback.__raw = ''
          function()
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
          end
        '';
      }
    ];
  };
}
