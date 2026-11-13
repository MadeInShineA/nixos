# home-manager as a NixOS module. Every aspect that ships a home part imports
# this aspect itself, so aspects work regardless of which users a host has.
{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
