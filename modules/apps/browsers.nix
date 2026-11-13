# Web browsers (librewolf is the default)
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.browsers = {
    imports = [ nixos.home-manager ];

    # Fallback for xdg-open on file types with no default (otherwise picks firefox)
    environment.sessionVariables.BROWSER = "librewolf";

    home-manager.sharedModules = [ homeManager.browsers ];
  };

  flake.modules.homeManager.browsers =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        librewolf
        # Firefox forced to X11/XWayland (fixes mouse input in GeForce Now)
        (symlinkJoin {
          name = "firefox";
          paths = [ firefox ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/firefox --set MOZ_ENABLE_WAYLAND 0
          '';
        })
      ];
    };
}
