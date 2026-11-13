{
  description = "My NixOS configuration (dendritic: every file in ./modules is a flake-parts module)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Separate nixpkgs pin so noctalia can be updated on its own
    nixpkgs-noctalia.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Imports every .nix file under a directory (paths containing `/_` are skipped)
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    # Horizon: Minecraft Java Edition rewritten in Rust (https://playhorizon.dev)
    horizon = {
      url = "github:horizon-rust/horizon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
