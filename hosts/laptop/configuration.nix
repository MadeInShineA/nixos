{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
  ];

  # Laptop-specific identity
  networking.hostName = "laptop-host";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.grub.useOSProber = true;

  # Disable touchscreen (ELAN9008) only
  systemd.services.disable-touchscreen = let
    unbindScript = pkgs.writeShellScript "unbind-touchscreen" ''
      cd /sys/bus/hid/drivers/hid-multitouch
      for dev in 0018:04F3:2E36.*; do
        [ -e "$dev" ] && echo "$dev" > unbind || true
      done
    '';
  in {
    description = "Disable touchscreen by unbinding from hid-multitouch";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${unbindScript}";
      RemainAfterExit = true;
    };
  };
}
