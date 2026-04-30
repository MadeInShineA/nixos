{ ... }:
{
  flake.homeModules.zed =
    { pkgs-unstable, ... }:
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
    };
}
