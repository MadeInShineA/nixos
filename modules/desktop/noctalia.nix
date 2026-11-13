# Noctalia desktop shell (bar, launcher, notifications...; config: ./config/noctalia)
{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.noctalia =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      # noctalia comes from its own nixpkgs pin so it can be updated separately
      nixpkgs.overlays = [
        (final: prev: {
          noctalia = inputs.nixpkgs-noctalia.legacyPackages.${prev.stdenv.hostPlatform.system}.noctalia;
        })
      ];

      environment.systemPackages = with pkgs; [
        noctalia
        # GTK3 theme (noctalia switches between adw-gtk3 / adw-gtk3-dark)
        adw-gtk3
      ];

      # For the screen recorder plugin (gpu-screen-recorder + gsr-kms-server setcap wrapper)
      programs.gpu-screen-recorder.enable = true;

      home-manager.sharedModules = [ homeManager.noctalia ];
    };

  flake.modules.homeManager.noctalia =
    { config, pkgs, ... }:
    {
      # Noctalia keeps both its settings and its state in this directory
      xdg.configFile.noctalia = {
        source = config.dotfiles.link "noctalia";
        recursive = true;
      };
      xdg.stateFile.noctalia.source = config.dotfiles.link "noctalia";

      # For screen recording region selection
      home.packages = [ pkgs.slurp ];
    };
}
