# Streaming and downloads
{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        stremio-linux-shell
        # qBittorrent with python3 on its PATH only (needed for search plugins)
        (symlinkJoin {
          name = "qbittorrent-enhanced";
          paths = [ qbittorrent-enhanced ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/qbittorrent --prefix PATH : ${python3}/bin
          '';
        })
      ];
    };
}
