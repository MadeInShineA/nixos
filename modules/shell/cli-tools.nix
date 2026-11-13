# Small terminal utilities
{
  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        btop
        nitch
      ];
    };
}
