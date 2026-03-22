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
    "pipe-operators"
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
    shell = pkgs.nushell;
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable distrobox
  virtualisation.podman = {
    enable = true;
    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

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

  # Allow lock on lid down / up + Disable power button behavior (handled by hyprland)
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "ignore";
  };

  # Enable tailscale
  services.tailscale.enable = true;

  # Enable mullvad VPN
  services.resolved.enable = true;

  services.mullvad-vpn = {
    enable = true;

    # For the gui tool
    # package = pkgs.mullvad-vpn;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Power management
  # services.power-profiles-daemon.enable = true;

  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

    };
  };

  system.stateVersion = "25.11";
}
