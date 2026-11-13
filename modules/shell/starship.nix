# Starship prompt (config: ./config/starship.toml)
{
  flake.modules.homeManager.starship =
    { config, ... }:
    {
      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      xdg.configFile."starship.toml" = {
        source = config.dotfiles.link "starship.toml";
        recursive = true;
      };
    };
}
