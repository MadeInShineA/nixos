{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  # nix run .#vscodium
  # VSCodium writes to its user dir, so the settings are copied into a writable
  # state dir (~/.local/state/nix-run/vscodium) on every launch; extensions are
  # bundled read-only (vscode-with-extensions).
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    let
      hm = hmConfig [ homeManager.vscodium ];
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.vscodium = wrapApp {
        package = pkgs.vscode-with-extensions.override {
          vscode = hm.programs.vscodium.package;
          vscodeExtensions = hm.programs.vscodium.profiles.default.extensions;
        };
        exe = "codium";
        stateDir = "vscodium";
        copyFiles."User/settings.json" = "${hm.home-files}/.config/VSCodium/User/settings.json";
        shellFlags = [ ''--user-data-dir="$STATE_DIR"'' ];
      };
    };

  flake.modules.homeManager.vscodium =
    { pkgs, ... }:
    {
      programs.vscodium = {
        enable = true;

        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          extensions =
            with pkgs.vscode-extensions;
            [
              jnoortheen.nix-ide
              mkhl.direnv
              catppuccin.catppuccin-vsc
              catppuccin.catppuccin-vsc-icons
              quarto.quarto
              myriad-dreamin.tinymist
              streetsidesoftware.code-spell-checker
              aaron-bond.better-comments
              tamasfe.even-better-toml
              vue.volar
              bmewburn.vscode-intelephense-client
              thenuprojectcontributors.vscode-nushell-lang
              ms-azuretools.vscode-docker
              scalameta.metals
              scala-lang.scala
              haskell.haskell
              justusadam.language-haskell
              reditorsupport.r
              llvm-vs-code-extensions.vscode-clangd
              gleam.gleam
              redhat.java
              golang.go
              rust-lang.rust-analyzer
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "vscode-helix-emulation";
                publisher = "jasew";
                version = "0.6.2";
                sha256 = "14kgjfqik53lg0c1cqgv04pv3cs0kipm6w6wk88jdz2yasxx7zjp";
              }
            ];

          userSettings = {
            "editor.formatOnSave" = true;

            "telemetry.telemetryLevel" = "off";

            "workbench.sideBar.location" = "left";
            "workbench.colorTheme" = "Catppuccin Mocha";
            "workbench.iconTheme" = "catppuccin-mocha";

            "editor.bracketPairColorization.enabled" = true;

            "editor.inlayHints.enabled" = "on";

            "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
            "editor.fontSize" = 16;
            "editor.fontLigatures" = true;

            "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
            "terminal.integrated.defaultProfile.linux" = "nu";
            "terminal.integrated.profiles.linux" = {
              nu = {
                path = "nu";
              };
            };

            "direnv.restart.automatic" = true;

            "rust-analyzer.check.command" = "clippy";

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";

            "[cpp]" = {
              "editor.tabSize" = 2;
              "editor.insertSpaces" = true;
            };
          };
        };
      };
    };
}
