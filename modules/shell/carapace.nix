# Carapace: command-line completions
{
  flake.modules.homeManager.carapace = {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
