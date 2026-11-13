{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [ networkmanager-openconnect ];
      };

      programs.nm-applet.enable = true;
    };
}
