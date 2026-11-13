# Laptop host: picks the system aspects it wants, plus laptop-only settings.
{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.nixosConfigurations.laptop-host = inputs.nixpkgs.lib.nixosSystem {
    modules = [ nixos.laptop ];
  };

  flake.modules.nixos.laptop =
    { pkgs, ... }:
    {
      imports = with nixos; [
        ./_hardware-configuration.nix

        # System
        nix
        locale
        networking
        vpn
        audio
        bluetooth
        power
        virtualisation
        appimage
        fonts
        no-keyring

        # Desktop
        niri
        noctalia
        foot
        cosmic

        # Apps
        browsers
        ai
        gaming

        # Users
        madeinshinea
      ];

      networking.hostName = "laptop-host";

      # Bootloader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Disable touchscreen (ELAN9008) only
      systemd.services.disable-touchscreen =
        let
          unbindScript = pkgs.writeShellScript "unbind-touchscreen" ''
            cd /sys/bus/hid/drivers/hid-multitouch
            for dev in 0018:04F3:2E36.*; do
              [ -e "$dev" ] && echo "$dev" > unbind || true
            done
          '';
        in
        {
          description = "Disable touchscreen by unbinding from hid-multitouch";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${unbindScript}";
            RemainAfterExit = true;
          };
        };

      system.stateVersion = "25.11";
    };
}
