# VNC client (e.g. for remote lab machines)
{
  flake.modules.homeManager.remote-desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.turbovnc ];
    };
}
