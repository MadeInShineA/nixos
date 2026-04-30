{ ... }:
{
  flake.nixosModules.networking =
    { ... }:
    {
      networking.networkmanager.enable = true;

      services.tailscale.enable = true;

      services.resolved.enable = true;

      services.mullvad-vpn.enable = true;
    };
}
