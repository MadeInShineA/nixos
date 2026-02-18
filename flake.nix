{
  description ="My NixOs configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { nixpkgs, home-manager, silentSDDM, nvf, ... }: {
    nixosConfigurations = {
      vm-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/vm/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

	      sharedModules = [
	        nvf.homeManagerModules.default
	      ];

              users.madeinshinea = import ./common/home.nix;
              backupFileExtension = "backup";
            };
          }

	 silentSDDM.nixosModules.default
	 {
	    programs.silentSDDM = {
	      enable = true;
	      theme = "catppuccin-macchiato";
	     };
	  }
        ];
      };
      
      laptop-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/laptop/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

	      sharedModules = [
	        nvf.homeManagerModules.default
	      ];

              users.madeinshinea = import ./common/home.nix;
              backupFileExtension = "backup";
            };
          }

     /*
	 silentSDDM.nixosModules.default
	 {
	    programs.silentSDDM = {
	      enable = true;
	      theme = "catppuccin-macchiato";
	     };
	  }
	  */
      ];
      };
    };
  };
}
