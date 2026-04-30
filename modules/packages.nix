{ inputs, ... }:
{
  # Restrict evaluation to the only architecture this config targets.
  systems = [ "x86_64-linux" ];

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Mirror the same unstable snapshot used by the home modules.
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Helix wrapped with the same extra tools its Home Manager module uses,
      # so language tooling works identically whether installed or run directly.
      helixWithTools = pkgs.symlinkJoin {
        name = "helix-with-tools";
        paths = [ pkgs.helix ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.simple-completion-language-server
                pkgs.codebook
              ]
            }
        '';
      };
    in
    {
      # Every entry here becomes reachable via:
      #   nix run .#<name>
      #   nix run github:madeinshinea/nixos#<name>
      packages = {
        helix = helixWithTools;
        zed = pkgs-unstable.zed-editor;
        opencode = pkgs-unstable.opencode;
        zellij = pkgs-unstable.zellij;
        jujutsu = pkgs-unstable.jujutsu;
      };

      # symlinkJoin doesn't inherit meta.mainProgram from pkgs.helix, so nix run
      # wouldn't know which binary to invoke. An explicit apps entry fixes this.
      apps.helix = {
        type = "app";
        program = "${helixWithTools}/bin/hx";
      };
    };
}
