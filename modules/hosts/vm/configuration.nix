{ self, ... }:
{
  flake.nixosModules.vmConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.vmHardware
        self.nixosModules.nixSettings
        self.nixosModules.locale
        self.nixosModules.users
        self.nixosModules.hyprland
        self.nixosModules.bluetooth
        self.nixosModules.networking
        self.nixosModules.audio
        self.nixosModules.virtualisation
        self.nixosModules.power
        self.nixosModules.fonts
        self.nixosModules.systemPackages
        self.nixosModules.security
      ];

      networking.hostName = "vm-host";

      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vda";
      boot.loader.grub.useOSProber = true;

      services.spice-vdagentd.enable = true;

      system.stateVersion = "25.11";
    };
}
