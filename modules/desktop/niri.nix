# Niri: scrollable-tiling Wayland compositor (config: ./config/niri)
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # nix run .#niri (e.g. nested in another wayland session)
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.niri = wrapApp {
        package = pkgs.niri;
        env.NIRI_CONFIG = "${(hmConfig [ homeManager.niri ]).home-files}/.config/niri/config.kdl";
      };
    };

  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      programs.niri.enable = true;

      # For niri xwayland integration
      environment.systemPackages = [ pkgs.xwayland-satellite ];

      # Java/Swing apps (e.g. TurboVNC viewer) render blank under niri's xwayland-satellite
      environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

      home-manager.sharedModules = [ homeManager.niri ];
    };

  flake.modules.homeManager.niri =
    { config, pkgs, ... }:
    {
      xdg.configFile.niri = {
        source = config.dotfiles.link "niri";
        recursive = true;
      };

      # Wayland clipboard: CLI tools + keep the clipboard after the source app closes
      home.packages = [ pkgs.wl-clipboard ];
      services.wl-clip-persist.enable = true;
    };
}
