# Git + GitHub CLI. The identity (name / email) comes from the user's profile.
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  # nix run .#git (with my identity)
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    let
      hm = hmConfig [
        homeManager.git
        homeManager.madeinshinea-identity
      ];
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.git = wrapApp {
        package = hm.programs.git.package;
        env.GIT_CONFIG_GLOBAL = "${hm.home-files}/.config/git/config";
      };
    };

  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      programs.git.enable = true;
      home.packages = [ pkgs.gh ];
    };
}
