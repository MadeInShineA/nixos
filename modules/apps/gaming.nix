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

      nixpkgs.overlays = [
        inputs.horizon.overlays.default
      ];

      programs.steam.enable = true;
      # Extra libs inside the steam-run FHS env (needed by MeleeUnlocked)
      programs.steam.extraPackages = with pkgs; [
        libxscrnsaver
        libdecor
      ];
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
      imports = [ inputs.slippi.homeManagerModules.default ];

      home.packages = with pkgs; [
        prismlauncher
        horizon-launcher
        ares
        # Force XWayland: native Wayland at fractional scale (1.75) renders off-centre
        (symlinkJoin {
          name = "azahar";
          paths = [ azahar ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/azahar --set QT_QPA_PLATFORM xcb";
        })
        antimicrox
      ];
    };
}
