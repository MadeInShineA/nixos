{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Separate nixpkgs pin so noctalia can be updated on its own
    nixpkgs-noctalia.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    # Horizon: Minecraft Java Edition rewritten in Rust (https://playhorizon.dev)
    horizon = {
      url = "github:horizon-rust/horizon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
              inputs.horizon.overlays.default
              (final: prev: {
                noctalia = inputs.nixpkgs-noctalia.legacyPackages.${prev.stdenv.hostPlatform.system}.noctalia;
              })
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
