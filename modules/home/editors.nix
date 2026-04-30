{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

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
    ];

    installRemoteServer = true;

    userSettings = {
      telemetry.metrics = false;

      git_panel.dock = "left";
      debugger.dock = "left";
      project_panel.dock = "left";
      agent_panel.dock = "right";

      agent = {
        sidebar_side = "right";
        dock = "right";
      };

      disable_ai = false;

      agent_servers.OpenCode = {
        command = "opencode";
        args = [ "acp" ];
      };

      colorize_brackets = true;
      theme = "Catppuccin Mocha";
      helix_mode = true;

      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
      };

      ui_font_size = 16;
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 16;

      terminal.font_family = "JetBrainsMono Nerd Font";

      lsp.rust-analyzer.initialization_options.check.command = "clippy";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "catppuccin_mocha_transparent";

      editor.bufferline = "multiple";
      editor.line-number = "relative";
      editor.inline-diagnostics.cursor-line = "warning";
      editor.inline-diagnostics.other-lines = "warning";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.file-picker.hidden = false;
    };

    languages = {
      language-server.codebook = {
        command = "codebook-lsp";
        args = [ "serve" ];
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
          language-servers = [ "nixd" ];
        }
        {
          name = "rust";
          auto-format = true;
          formatter.command = lib.getExe pkgs.clippy;
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = lib.getExe pkgs.deno;
            args = [
              "fmt"
              "-"
              "--ext"
              "md"
            ];
          };
          language-servers = [
            "marksman"
            "codebook"
          ];
          file-types = [
            "md"
            "mdx"
            "qmd"
          ];
        }
      ];
    };

    themes.catppuccin_mocha_transparent = {
      "inherits" = "catppuccin_mocha";
      "ui.background" = { };
    };

    extraPackages = [
      pkgs.simple-completion-language-server
      pkgs.codebook
    ];
  };
}
