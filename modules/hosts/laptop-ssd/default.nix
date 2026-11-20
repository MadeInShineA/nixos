# Laptop booted from the external SSD: same setup as the laptop host, different hardware.
{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.nixosConfigurations.laptop-ssd = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos.laptop
      ./_hardware-configuration.nix
      { networking.hostName = "laptop-ssd"; }
    ];
  };
}
