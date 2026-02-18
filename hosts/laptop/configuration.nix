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
}
