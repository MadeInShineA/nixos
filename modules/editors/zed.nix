{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  # nix run .#zed
  # Zed writes to its config dir, so the settings are copied into a writable
  # state dir (~/.local/state/nix-run/zed) on every launch.
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
        homeManager.zed
        # Write settings.json as a plain file instead of merging it on activation
        { programs.zed-editor.mutableUserSettings = false; }
      ];
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.zed = wrapApp {
        package = hm.programs.zed-editor.package;
        stateDir = "zed";
        copyFiles."config/settings.json" = "${hm.home-files}/.config/zed/settings.json";
        shellFlags = [ ''--user-data-dir="$STATE_DIR"'' ];
      };
    };

  flake.modules.homeManager.zed = {
    # `zed` opens the current directory
    programs.nushell.shellAliases.zed = "zeditor .";

    programs.zed-editor = {
      enable = true;

      extensions = [
        "nix"
        "catppuccin"
        "quarto"
        "typst"
        "codebook"
        "comment"
        "toml"
        "vue"
        "php"
        "nu"
        "dockerfile"
        "scala"
        "haskell"
        "r"
        "c"
        "cpp"
        "cuda"
        "gleam"
        "java"
        "go"
      ];

      installRemoteServer = true;

      userSettings = {
        format_on_save = "on";

        telemetry = {
          metrics = false;
        };

        git_panel = {
          dock = "left";
        };

        debugger = {
          dock = "left";
        };

        project_panel = {
          dock = "left";
        };

        agent = {
          dock = "right";
        };

        disable_ai = false;

        agent_servers = {
          OpenCode = {
            command = "opencode";
            args = [ "acp" ];
          };
        };

        theme = "Catppuccin Mocha";
        helix_mode = true;

        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
        };

        diagnostics.inline = {
          enabled = true;
          max_severity = "warning";

        };

        ui_font_size = 16;

        buffer_font_family = "JetBrainsMono Nerd Font";
        buffer_font_size = 16;

        terminal = {
          font_family = "JetBrainsMono Nerd Font";
          shell = {
            program = "nu";
          };
        };

        lsp = {
          rust-analyzer = {
            initialization_options = {
              check = {
                command = "clippy";
              };
            };
          };
        };

        languages = {
          "C++" = {
            tab_size = 2;
            hard_tabs = false;
          };
        };
      };
    };
  };
}
