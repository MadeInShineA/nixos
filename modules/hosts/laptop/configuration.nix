{ self, ... }:
{
  flake.nixosModules.laptopConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.laptopHardware
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

      networking.hostName = "laptop-host";

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      system.stateVersion = "25.11";
    };
}
