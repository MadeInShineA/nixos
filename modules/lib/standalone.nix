# Helpers to expose configured apps as flake packages (`nix run .#<app>`).
# They are module arguments of every `perSystem`.
#
# A standalone app always takes its config from the app's homeManager aspect,
# the same one the hosts use: `hmConfig [ homeManager.<app> ]` evaluates the
# aspect on its own (dotfiles copied into the store instead of linked), then
# `wrapApp` points the program at the generated files.
{ inputs, config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  perSystem =
    { pkgs, lib, ... }:
    {
      _module.args = {
        # home-manager config of the given aspects alone.
        # `.home-files` holds the generated files, laid out as in $HOME.
        hmConfig =
          modules:
          (inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              homeManager.dotfiles
              {
                dotfiles.mutable = false;
                home.username = "nix-run";
                home.homeDirectory = "/home/nix-run";
                home.stateVersion = "25.11";
              }
            ]
            ++ modules;
          }).config;

        # Wrap the main program of `package`:
        #   flags      arguments passed as-is
        #   env        environment variables to set
        #   path       packages appended to PATH
        #   stateDir   for apps that write to their config dir: a writable dir,
        #              ~/.local/state/nix-run/<stateDir>, available as "$STATE_DIR"
        #              in `shellFlags` ...
        #   copyFiles  ... and filled with { "<path in STATE_DIR>" = <file>; } on every launch
        #   shellFlags arguments expanded by the wrapper's shell (e.g. "--dir=$STATE_DIR")
        wrapApp =
          {
            package,
            exe ? package.meta.mainProgram,
            flags ? [ ],
            env ? { },
            path ? [ ],
            stateDir ? null,
            copyFiles ? { },
            shellFlags ? [ ],
          }:
          let
            setup = lib.optionalString (stateDir != null) ''
              STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/nix-run/${stateDir}"
              ${lib.concatStrings (
                lib.mapAttrsToList (dest: src: ''
                  ${pkgs.coreutils}/bin/install -Dm644 ${src} "$STATE_DIR/${dest}"
                '') copyFiles
              )}
            '';

            wrapperArgs =
              lib.concatLists (
                lib.mapAttrsToList (name: value: [
                  "--set"
                  name
                  value
                ]) env
              )
              ++ lib.optionals (path != [ ]) [
                "--suffix"
                "PATH"
                ":"
                (lib.makeBinPath path)
              ]
              ++ lib.optionals (setup != "") [
                "--run"
                setup
              ]
              ++ lib.concatMap (flag: [
                "--add-flag"
                flag
              ]) flags
              ++ lib.optionals (shellFlags != [ ]) [
                "--add-flags"
                (lib.concatStringsSep " " shellFlags)
              ];
          in
          pkgs.symlinkJoin {
            name = "${exe}-configured";
            paths = [ package ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = "wrapProgram $out/bin/${exe} ${lib.escapeShellArgs wrapperArgs}";
            meta = removeAttrs package.meta [ "outputsToInstall" ] // {
              mainProgram = exe;
            };
          };
      };
    };
}
