# The madeinshinea user: system account + home-manager profile.
#
# - homeManager.madeinshinea: the user's own aspects (shell, editors, ...)
# - aspects that also need system config (niri, gaming, ...) are enabled per host
#   and add their home part to every user through `home-manager.sharedModules`
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.madeinshinea =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      users.users.madeinshinea = {
        isNormalUser = true;
        description = "madeinshinea";
        shell = pkgs.nushell;
        extraGroups = [
          "networkmanager"
          "wheel"
          "podman"
          "libvirtd"
        ];
      };

      home-manager.users.madeinshinea.imports = [ homeManager.madeinshinea ];
    };

  flake.modules.homeManager.madeinshinea = {
    imports = with homeManager; [
      madeinshinea-identity
      dotfiles
      xdg

      # Shell
      nushell
      starship
      direnv
      carapace
      tmux
      yazi
      cli-tools

      # Development
      git
      nix-tools
      nvim
      zed
      vscodium

      # Apps
      communication
      media
      notes
      passwords
      remote-desktop
    ];

    home.username = "madeinshinea";
    home.homeDirectory = "/home/madeinshinea";
    home.stateVersion = "25.11";
  };

  # Who I am, for tools that need it (also used by the standalone `git` package)
  flake.modules.homeManager.madeinshinea-identity = {
    programs.git.settings.user = {
      name = "Olivier Amacker";
      email = "olivier.amacker@netplus.ch";
    };
  };
}
