# Flake-level setup shared by every other module.
#
# Each file in ./modules contributes "aspects" to `flake.modules.<class>.<name>`
# (class = nixos | homeManager). Hosts then pick the aspects they want.
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Systems for which `packages` (e.g. `nix run .#nvim`) are exposed
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # nixpkgs used by `packages` (same unfree policy as the hosts)
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
}
