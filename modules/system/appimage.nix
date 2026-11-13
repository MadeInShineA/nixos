{
  flake.modules.nixos.appimage =
    { pkgs, ... }:
    {
      programs.appimage = {
        enable = true;
        binfmt = true;

        package = pkgs.appimage-run.override {
          extraPkgs =
            pkgs: with pkgs; [
              curl
              openssl
              libepoxy
              libgpg-error
            ];
        };
      };
    };
}
