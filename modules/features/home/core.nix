{ ... }:
{
  flake.homeModules.core =
    { config, ... }:
    {
      home.username = "madeinshinea";
      home.homeDirectory = "/home/madeinshinea";

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        pictures = "${config.home.homeDirectory}/Pictures";
      };

      home.stateVersion = "25.11";
    };
}
