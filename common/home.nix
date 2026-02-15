{ config, pkgs, ... }: 
let 
  dotfiles = "${config.home.homeDirectory}/nixos/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    foot = "foot";
    hypr = "hypr";
    waybar = "waybar";
    # nvim = "nvim";
    rofi = "rofi";
  };

in
{
  home.username = "madeinshinea";
  home.homeDirectory = "/home/madeinshinea";

  # Universal user packages
  home.packages = with pkgs; [
    fastfetch
    vesktop
  ];

  # Universal user programs config
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Olivier Amacker";
        email = "olivier.amacker@netplus.ch";
      };
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.stateVersion = "25.11";
}
