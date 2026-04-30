{ ... }:
{
  flake.nixosModules.audio =
    { ... }:
    {
      services.pipewire.pulse.enable = true;
    };
}
