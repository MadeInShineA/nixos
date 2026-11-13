# COSMIC settings (config: ./config/cosmic; cosmic apps / portal are used under niri)
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.cosmic = {
    imports = [ nixos.home-manager ];
    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";
    home-manager.sharedModules = [ homeManager.cosmic ];
  };

  flake.modules.homeManager.cosmic =
    { config, ... }:
    {
      xdg.configFile.cosmic = {
        source = config.dotfiles.link "cosmic";
        recursive = true;
      };
    };
}
