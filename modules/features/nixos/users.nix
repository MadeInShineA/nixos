{ ... }:
{
  flake.nixosModules.users =
    { pkgs, ... }:
    {
      users.users.madeinshinea = {
        isNormalUser = true;
        description = "madeinshinea";
        shell = pkgs.nushell;
        extraGroups = [
          "networkmanager"
          "wheel"
          "podman"
        ];
        packages = [ ];
      };
    };
}
