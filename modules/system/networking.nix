{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [ networkmanager-openconnect ];

        ensureProfiles = {
          profiles = {
            eduroam = {
              connection = {
                id = "eduroam";
                type = "wifi";
              };
              wifi = {
                ssid = "eduroam";
                mode = "infrastructure";
              };
              wifi-security.key-mgmt = "wpa-eap";
              "802-1x" = {
                eap = "peap;";
                phase2-auth = "mschapv2";
              };
              ipv4.method = "auto";
              ipv6.method = "auto";
            };

            "VPN connection 1" = {
              connection = {
                id = "He-arc VPN";
                type = "vpn";
                autoconnect = false;
              };
              vpn = {
                service-type = "org.freedesktop.NetworkManager.openconnect";
                protocol = "anyconnect";
                gateway = "webvpn.he-arc.ch";
                authtype = "password";
                useragent = "AnyConnect";
                stoken_source = "disabled";
                enable_csd_trojan = "no";
                disable_udp = "no";
                pem_passphrase_fsid = "no";
                prevent_invalid_cert = "no";
                autoconnect-flags = "0";
                certsigs-flags = "0";
                cookie-flags = "2";
                gateway-flags = "2";
                gwcert-flags = "2";
                lasthost-flags = "0";
                resolve-flags = "2";
                xmlconfig-flags = "0";
              };
              ipv4.method = "auto";
              ipv6.method = "auto";
            };
          };
        };
      };

      programs.nm-applet.enable = true;
    };
}
