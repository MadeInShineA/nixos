# Neovim, configured with nixvim and fully self-contained.
#
#   nix run github:MadeInShineA/nixos#nvim
#
# Every other file in this directory adds one feature (its plugins, settings
# and keymaps) to the `flake.modules.nixvim.nvim` module. Deleting a file
# removes the feature completely.
#
# Language servers are NOT bundled: they are expected to come from project
# flakes (direnv); a server is only enabled when its binary is on PATH.
{ inputs, config, ... }:
let
  mkNvim =
    pkgs:
    inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
      inherit pkgs;
      module = config.flake.modules.nixvim.nvim;
    };
in
{
  # nix run .#nvim
  perSystem =
    { pkgs, ... }:
    {
      packages.nvim = mkNvim pkgs;
    };

  # Same package on hosts, as the default editor
  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    let
      editor = {
        EDITOR = "nvim";
        VIEW = "nvim";
      };
    in
    {
      home.packages = [ (mkNvim pkgs) ];
      home.sessionVariables = editor;
      programs.nushell.environmentVariables = editor;
    };

  # Base settings shared by all features
  flake.modules.nixvim.nvim =
    { pkgs, ... }:
    {
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      opts = {
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        cursorline = true;
        termguicolors = true;
        mouse = "a";
        ignorecase = true;
        smartcase = true;
        scrolloff = 8;
        splitright = true;
        splitbelow = true;
        undofile = true;
        updatetime = 250;
        showmode = false;
        foldlevelstart = 99;
      };

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;
      };

      keymaps = [
        {
          mode = "n";
          key = "<S-l>";
          action = "<cmd>BufferLineCycleNext<cr>";
          options.desc = "Next buffer";
        }
        {
          mode = "n";
          key = "<S-h>";
          action = "<cmd>BufferLineCyclePrev<cr>";
          options.desc = "Prev buffer";
        }
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<cr>";
        }
      ];
    };
}
