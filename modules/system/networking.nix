{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [ networkmanager-openconnect ];

        ensureProfiles = {
          # Gitignored KEY=VALUE file (also loaded by nushell); provides EDUROAM_IDENTITY
          environmentFiles = [ "/home/madeinshinea/nixos/.env" ];
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
                identity = "$EDUROAM_IDENTITY";
                # Agent-owned secret: nm-applet prompts for the password, so it never lands in
                # this config or the Nix store. No keyring on this system, so it isn't remembered.
                password-flags = "1";
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

      # ASIX AX88179A USB-C ethernet dongle (cdc_ncm driver) comes back from suspend with
      # "no carrier". Re-enumerate it after resume so it behaves like a fresh plug-in.
      # (The vendor ax88179_178a driver doesn't work with the AX88179A, so don't switch to it.)
      powerManagement.resumeCommands = ''
        for dev in /sys/bus/usb/devices/*; do
          if [ "$(cat "$dev/idVendor" 2>/dev/null)" = "0b95" ] && [ "$(cat "$dev/idProduct" 2>/dev/null)" = "1790" ]; then
            echo 0 > "$dev/authorized"
            sleep 1
            echo 1 > "$dev/authorized"
          fi
        done
      '';

      programs.nm-applet.enable = true;

      home-manager.sharedModules = [ homeManager.networking ];
    };

  # Hide the autostart nm-applet (no --indicator), tray clicks don't work with it on niri
  flake.modules.homeManager.networking = {
    xdg.configFile."autostart/nm-applet.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=NetworkManager Applet
      Hidden=true
    '';
  };
}
