# Foot terminal (config: ./config/foot)
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # nix run .#foot
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.foot = wrapApp {
        package = pkgs.foot;
        flags = [ "--config=${(hmConfig [ homeManager.foot ]).home-files}/.config/foot/foot.ini" ];
      };
    };

  flake.modules.nixos.foot =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];
      environment.systemPackages = [ pkgs.foot ];
      home-manager.sharedModules = [ homeManager.foot ];
    };

  flake.modules.homeManager.foot =
    { config, ... }:
    {
      xdg.configFile.foot = {
        source = config.dotfiles.link "foot";
        recursive = true;
      };
    };
}
