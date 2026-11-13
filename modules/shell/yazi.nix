# Yazi file manager (config: ./config/yazi)
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;

  # yazi + the tools its config/plugins need, used by hosts and `nix run`
  mkYazi =
    pkgs:
    let
      # nixpkgs' yazi already bundles fd, ripgrep, 7zz, ffmpeg, zoxide, ...
      yazi = pkgs.yazi.override {
        extraPackages = [
          pkgs.git # git.yazi plugin
        ]
        ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.wl-clipboard; # wl-clipboard.yazi plugin
      };
    in
    pkgs.symlinkJoin {
      name = "yazi";
      paths = [ yazi ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # POSIX shell for yazi's `shell` commands (e.g. extraction), whatever the login shell
      postBuild = "wrapProgram $out/bin/yazi --set SHELL ${pkgs.lib.getExe pkgs.bash}";
      meta.mainProgram = "yazi";
    };
in
{
  # nix run .#yazi
  perSystem =
    {
      pkgs,
      hmConfig,
      wrapApp,
      ...
    }:
    {
      packages.yazi = wrapApp {
        package = mkYazi pkgs;
        env.YAZI_CONFIG_HOME = "${(hmConfig [ homeManager.yazi ]).home-files}/.config/yazi";
      };
    };

  flake.modules.homeManager.yazi =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        (mkYazi pkgs)
        zoxide
        p7zip
      ];

      xdg.configFile.yazi = {
        source = config.dotfiles.link "yazi";
        recursive = true;
      };
    };
}
