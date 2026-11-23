# AdGuard Home: local DNS ad/tracker blocker, used with and without Mullvad.
# Web UI: http://127.0.0.1:3000
#
# Chain: apps -> systemd-resolved (127.0.0.53) -> AdGuard Home (127.0.0.1:53) -> DoH upstreams
# With Mullvad connected, Mullvad's custom DNS points at AdGuard Home too, and the DoH
# upstream traffic goes through the tunnel.
{
  flake.modules.nixos.adguardhome =
    { config, lib, ... }:
    {
      services.adguardhome = {
        enable = true;
        settings = {
          http.address = "127.0.0.1:3000";
          theme = "dark";
          dns = {
            bind_hosts = [ "127.0.0.1" ];
            port = 53;
            upstream_dns = [
              "https://9.9.9.9/dns-query"
              "https://149.112.112.112/dns-query"
            ];
            bootstrap_dns = [
              "https://9.9.9.9/dns-query"
              "https://1.1.1.1/dns-query"
            ];
          };
          filtering = {
            protection_enabled = true;
            filtering_enabled = true;
          };
          filters = [
            {
              enabled = true;
              id = 1;
              name = "AdGuard DNS filter";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            }
            {
              enabled = true;
              id = 48;
              name = "HaGeZi's Pro Blocklist";
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt";
            }
          ];
        };
      };

      # Send every query from resolved to AdGuard Home
      services.resolved.settings.Resolve = {
        DNS = [ "127.0.0.1" ];
        Domains = [ "~." ];
      };

      # Ignore DNS servers handed out by Wi-Fi/Ethernet DHCP, otherwise resolved would
      # query them too and bypass the blocker. VPN connections (e.g. He-arc) keep their DNS.
      networking.networkmanager.settings."connection-adguard" = {
        match-device = "type:wifi,type:ethernet";
        "ipv4.ignore-auto-dns" = true;
        "ipv6.ignore-auto-dns" = true;
      };

      # Make Mullvad use AdGuard Home as its custom DNS server while connected
      systemd.services.mullvad-adguard-dns = lib.mkIf config.services.mullvad-vpn.enable {
        description = "Point Mullvad's custom DNS at AdGuard Home";
        after = [ "mullvad-daemon.service" ];
        requires = [ "mullvad-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = 2;
        };
        script = "${config.services.mullvad-vpn.package}/bin/mullvad dns set custom 127.0.0.1";
      };
    };
}
