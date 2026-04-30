{ ... }:
{
  flake.homeModules.helix =
    { pkgs, lib, ... }:
    {
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
    };
}
