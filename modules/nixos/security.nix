{ ... }:
{
  # Lock on lid down/up; disable power button (handled by Hyprland)
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "ignore";
  };
}
