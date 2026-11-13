{
  flake.modules.homeManager.nix-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Nix language servers
        nixd
        nil
        # Rebuild helper
        nh
      ];
    };
}
