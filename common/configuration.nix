{
  config,
  pkgs,
  ...
}:
{
  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic cleanup and optimization
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Universal settings
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };
  console.keyMap = "fr_CH";

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # User account
  users.users.madeinshinea = {
    isNormalUser = true;
    description = "madeinshinea";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Packages/services
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;

  # Desktop environment
  /*
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;

    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      ark
      okular
      khelpcenter
      baloo-widgets
      krdp
      konsole
      gwenview
    ];
  */

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    foot
    rofi
    rofi-power-menu
    waybar
    kdePackages.dolphin

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
  ];

  # Enable docker system wide
  virtualisation.docker.enable = true;

  # Allow lock on lid down / up + Disable power button behavior (handled by hyprland)
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "ignore";
  };

  services.power-profiles-daemon.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.11";
}
