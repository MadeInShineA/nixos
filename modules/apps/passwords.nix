# Password manager
{
  flake.modules.homeManager.passwords =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bitwarden-desktop ];
    };
}
