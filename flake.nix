{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    {
      nixosConfigurations.laptop-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/laptop/configuration.nix

          {
            nixpkgs.overlays = [
              (final: _prev: {
                pnpm_10_29_2 = final.pnpm_10;
              })
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              users.madeinshinea = import ./common/home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
