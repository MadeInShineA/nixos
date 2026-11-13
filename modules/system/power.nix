{
  flake.modules.nixos.power =
    { pkgs, ... }:
    {
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
          CPU_MAX_PERF_ON_BAT = 10;

          STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
        };
      };

      services.upower.enable = true;

      # Lock on lid close + power button handled by the compositor
      services.logind.settings.Login = {
        HandleLidSwitch = "lock";
        HandleLidSwitchExternalPower = "lock";
        HandlePowerKey = "ignore";
      };

      # Brightness control from the command line / keybinds
      environment.systemPackages = [ pkgs.brightnessctl ];
    };
}
