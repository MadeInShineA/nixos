{
  flake.modules.nixos.audio =
    { pkgs, ... }:
    {
      # Pipewire pulse, for bluetooth sink switch
      services.pipewire.pulse.enable = true;

      # Volume control from the command line / keybinds
      environment.systemPackages = [ pkgs.pamixer ];
    };
}
