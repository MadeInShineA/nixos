# Games, emulators and controllers
{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.gaming =
    { config, pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      nixpkgs.overlays = [ inputs.horizon.overlays.default ];

      programs.steam.enable = true;
      # Controller support
      hardware.steam-hardware.enable = true;

      # Dolphin emulator + GameCube adapter (udev rules, overclocked adapter driver)
      environment.systemPackages = [ pkgs.dolphin-emu ];
      services.udev.packages = [ pkgs.dolphin-emu ];
      boot.extraModulePackages = [ config.boot.kernelPackages.gcadapter-oc-kmod ];
      boot.kernelModules = [ "gcadapter_oc" ];

      home-manager.sharedModules = [ homeManager.gaming ];
    };

  flake.modules.homeManager.gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        prismlauncher
        horizon-launcher # from the horizon overlay
        ares
        azahar
        antimicrox
      ];
    };
}
