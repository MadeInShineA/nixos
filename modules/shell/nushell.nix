# Nushell, my login shell. Other aspects plug into it (prompt, completions,
# aliases, ...) through `programs.nushell.*` themselves.
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  # nix run .#nushell (with the prompt / completions / direnv integrations)
  perSystem =
    {
      pkgs,
      lib,
      hmConfig,
      wrapApp,
      ...
    }:
    let
      hm = hmConfig (
        with homeManager;
        [
          nushell
          starship
          carapace
          direnv
        ]
      );
      files = "${hm.home-files}/.config";
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      packages.nushell = wrapApp {
        package = hm.programs.nushell.package;
        flags = [
          "--config"
          "${files}/nushell/config.nu"
          "--env-config"
          "${files}/nushell/env.nu"
        ];
        env.STARSHIP_CONFIG = "${files}/starship.toml";
      };
    };

  flake.modules.homeManager.nushell = {
    programs.nushell = {
      enable = true;
      settings.show_banner = false;

      extraConfig = ''
        # Load secrets from ~/nixos/.env (KEY=VALUE lines, not in git)
        let env_path = ($env.HOME | path join "nixos" ".env")

        if ($env_path | path exists) {
          # 1. Read and clean lines
          let lines = (open $env_path --raw | lines | each { |l| $l | str trim } | where { |l| $l != "" and not ($l | str starts-with "#") })

          # 2. Parse into a record { KEY: "VALUE" }
          let env_record = ($lines
            | parse "{key}={value}"
            | reduce -f {} { |it acc|
                let k = ($it.key | str trim)
                let v = ($it.value | str trim | str replace --all '"' "" | str replace --all "'" "")
                $acc | upsert $k $v
              }
          )

          # 3. Load the record into the environment
          load-env $env_record
        }
      '';

      extraEnv = ''
        $env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin" | uniq)
        $env.XDG_SESSION_TYPE = "wayland"
      '';
    };
  };
}
