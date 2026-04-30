{ ... }:
{
  flake.homeModules.homeDesktop =
    { config, pkgs, ... }:
    let
      dotfiles = "${config.home.homeDirectory}/nixos/config";
      mkSymlink = path: config.lib.file.mkOutOfStoreSymlink path;

      configs = {
        foot = "foot";
        hypr = "hypr";
        waybar = "waybar";
        rofi = "rofi";
        mako = "mako";
        opencode = "opencode";
        "starship.toml" = "starship.toml";
      };
    in
    {
      programs.swappy = {
        enable = true;
        settings.Default.save_dir = "${config.xdg.userDirs.pictures}";
      };

      programs.anki = {
        enable = true;
        theme = "dark";
        addons = with pkgs.ankiAddons; [
          (anki-connect.withConfig {
            config.webCorsOriginList = [
              "http://localhost"
              "http://localhost:8765"
              "http://localhost:3000"
              "https://app.asbplayer.dev"
            ];
          })
        ];
      };

      xdg.configFile = builtins.mapAttrs (_name: subpath: {
        source = mkSymlink "${dotfiles}/${subpath}";
        recursive = true;
      }) configs;
    };
}
