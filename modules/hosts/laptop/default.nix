{ self, inputs, ... }:
{
  flake.nixosConfigurations.laptop-host = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.laptopConfiguration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ ];
          extraSpecialArgs = {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          users.madeinshinea = {
            imports = [
              self.homeModules.core
              self.homeModules.packages
              self.homeModules.git
              self.homeModules.shell
              self.homeModules.helix
              self.homeModules.zed
              self.homeModules.homeDesktop
              self.homeModules.inputMethod
            ];
          };
          backupFileExtension = "backup";
        };
      }
    ];
  };
}
