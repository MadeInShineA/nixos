{ ... }:
{
  flake.homeModules.shell =
    { ... }:
    {
      programs.tmux.enable = true;

      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableNushellIntegration = true;
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };

      programs.nushell = {
        enable = true;
        environmentVariables = {
          EDITOR = "hx";
          VIEW = "hx";
        };
        settings = {
          show_banner = false;
        };
        shellAliases = {
          zed = "zeditor .";
        };
      };
    };
}
