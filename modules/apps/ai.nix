# AI tools: Claude (desktop + code) and opencode
{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.ai = {
    imports = [ nixos.home-manager ];
    nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];
    home-manager.sharedModules = [ homeManager.ai ];
  };

  flake.modules.homeManager.ai =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        claude-desktop-fhs # from the claude-desktop overlay
        claude-code
        opencode
      ];

      xdg.configFile.opencode = {
        source = config.dotfiles.link "opencode";
        recursive = true;
      };
    };
}
