{
  flake.modules.nixos.vpn = {
    services.tailscale.enable = true;

    # Mullvad needs systemd-resolved
    services.resolved.enable = true;
    services.mullvad-vpn.enable = true;
  };
}
