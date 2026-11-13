# Note taking / spaced repetition
{
  flake.modules.homeManager.notes =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.remnote ];
    };
}
