{ ... }:
{
  flake.homeModules.packages =
    { pkgs, pkgs-unstable, ... }:
    {
      home.packages = with pkgs; [
        fastfetch
        btop

        yazi

        vesktop
        telegram-desktop
        qbittorrent-enhanced

        # Japanese fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        wl-clipboard

        # Nix LSP
        nixd
        nil

        # Unstable packages
        pkgs-unstable.jujutsu
        pkgs-unstable.opencode

        pkgs-unstable.zellij

        pkgs-unstable.cherry-studio
        pkgs-unstable.ollama
      ];
    };
}
