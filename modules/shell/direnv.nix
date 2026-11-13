# direnv + nix-direnv: per-project dev environments from project flakes
{
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };
}
