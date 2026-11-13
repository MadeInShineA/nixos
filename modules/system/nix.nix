{
  flake.modules.nixos.nix =
    { pkgs, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      # Automatic cleanup and optimization
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      nixpkgs.config.allowUnfree = true;

      # Needed by flakes
      environment.systemPackages = [ pkgs.git ];
    };
}
