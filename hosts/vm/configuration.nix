{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
  ];

  # VM-specific identity
  networking.hostName = "vm-host";
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # VM-specific service
  services.spice-vdagentd.enable = true;
}
