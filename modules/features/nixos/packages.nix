{ ... }:
{
  flake.nixosModules.systemPackages =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        git
        foot
        rofi
        rofi-power-menu
        waybar

        brave

        hyprpaper
        hyprlock
        hypridle

        # For audio / brightness control
        pamixer
        brightnessctl

        # For notifications
        mako
        libnotify

        # For screenshots
        grim
        slurp

        podman-tui
        podman-compose

        distrobox
      ];
    };
}
