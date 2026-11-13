{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  # nix run .#tmux
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    let
      hm = hmConfig [ homeManager.tmux ];
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.tmux = wrapApp {
        package = hm.programs.tmux.package;
        flags = [
          "-f"
          "${hm.home-files}/.config/tmux/tmux.conf"
        ];
      };
    };

  flake.modules.homeManager.tmux = {
    programs.tmux.enable = true;
  };
}
