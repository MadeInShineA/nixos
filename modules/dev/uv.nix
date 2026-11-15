# uv, restricted to Nix-provided interpreters.
# NixOS can't run uv's downloaded (generic-linux) CPython builds, and uv prefers
# them over the python on PATH, so a fresh .venv would end up unusable.
{
  flake.modules.homeManager.uv = {
    programs.uv = {
      enable = true;
      package = null; # config only: uv comes from each project's dev shell
      settings = {
        python-downloads = "never";
        python-preference = "only-system";
      };
    };
  };
}
