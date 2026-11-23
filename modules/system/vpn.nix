{
  flake.modules.nixos.vpn =
    { config, ... }:
    {
      services.tailscale.enable = true;

      # Mullvad needs systemd-resolved
      services.resolved.enable = true;
      services.mullvad-vpn = {
        enable = true;
        gui.enable = true;
      };

      systemd.services.mullvad-autoconnect = {
        description = "Enable Mullvad auto-connect";
        after = [ "mullvad-daemon.service" ];
        requires = [ "mullvad-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = 2;
        };
        script = "${config.services.mullvad-vpn.package}/bin/mullvad auto-connect set on";
      };
    };
}
