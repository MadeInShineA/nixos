# Terminals (:terminal and a floating toggleterm) running nushell
# (falls back to the default shell where nu isn't installed)
{
  flake.modules.nixvim.nvim = {
    # 'shell' defaults to $SHELL, which nix devshells (direnv) set to nixpkgs'
    # non-interactive bash (its prompt prints literal \[ \]). Use nu instead,
    # with the flags that keep :! / system() / :r ! working under nu.
    extraConfigLuaPre = ''
      if vim.fn.executable("nu") == 1 then
        vim.o.shell = vim.fn.exepath("nu")
        vim.o.shellcmdflag = "--login --stdin --no-newline -c"
        vim.o.shellredir = "out+err> %s"
        vim.o.shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
        vim.o.shelltemp = false
        vim.o.shellxescape = ""
        vim.o.shellxquote = ""
        vim.o.shellquote = ""
      end
    '';

    plugins.toggleterm = {
      enable = true;
      settings = {
        shell.__raw = "vim.o.shell";
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
