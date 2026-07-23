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

  # Disable touche screen
  systemd.services.disable-touchscreen = {
    description = "Disable touchscreen by unbinding from hid-multitouch";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Unbind both detected devices
      ExecStart = [
        "${pkgs.coreutils}/bin/echo 0018:04F3:2E36.0004 > /sys/bus/hid/drivers/hid-multitouch/unbind"
        "${pkgs.coreutils}/bin/echo 0018:04F3:31B9.0003 > /sys/bus/hid/drivers/hid-multitouch/unbind"
      ];
      # Ignore errors if a device is already unbound or missing
      RemainAfterExit = true;
    };
  };
}
