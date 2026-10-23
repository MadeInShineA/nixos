{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    {
      nixosConfigurations.laptop-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/laptop/configuration.nix

          {
            nixpkgs.overlays = [
              inputs.claude-desktop.overlays.default
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # extraSpecialArgs = { inherit inputs; };

              users.madeinshinea = import ./common/home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
