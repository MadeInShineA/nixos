# Chat, video calls and mail
{
  flake.modules.homeManager.communication =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
        telegram-desktop
        teams-for-linux
        thunderbird
      ];
    };
}
