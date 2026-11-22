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
    let
      # Install an extension from addons.mozilla.org through policies
      amo = slug: {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      };
    in
    {
      programs.librewolf = {
        enable = true;

        # Profiles live in the XDG location, not the module's default ~/.librewolf
        configPath = ".config/librewolf/librewolf";

        policies = {
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = amo "ublock-origin";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = amo "bitwarden-password-manager";
            # Catppuccin theme
            "{f5525f34-4102-4f6e-8478-3cf23cfeff7a}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/file/3880040/catppuccin-1.0.xpi";
            };
          };

          # Sites whose cookies survive LibreWolf's clear-on-shutdown
          Cookies.Allow = [
            "https://github.com"
            "https://kimi.ai"
            "https://login.microsoftonline.com"
            "https://outlook.cloud.microsoft"
            "https://teams.microsoft.com"
          ];
        };

        profiles.madeinshinea = {
          id = 0;
          isDefault = true;
          settings = {
            "extensions.activeThemeID" = "{f5525f34-4102-4f6e-8478-3cf23cfeff7a}";
          };
        };
      };

      home.packages = with pkgs; [
        mullvad-browser

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
