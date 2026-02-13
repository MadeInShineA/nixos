{ config, pkgs, ... }: {
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

  home.stateVersion = "25.11";
}
