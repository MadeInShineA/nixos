# XDG user directories + default applications (./config/mimeapps.list)
{
  flake.modules.homeManager.xdg =
    { config, ... }:
    {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        pictures = "${config.home.homeDirectory}/Pictures";
      };

      xdg.configFile."mimeapps.list" = {
        source = config.dotfiles.link "mimeapps.list";
        recursive = true;
      };
    };
}
