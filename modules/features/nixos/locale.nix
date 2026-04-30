{ ... }:
{
  flake.nixosModules.locale =
    { ... }:
    {
      time.timeZone = "Europe/Zurich";
      i18n.defaultLocale = "en_US.UTF-8";

      services.xserver.xkb = {
        layout = "ch";
        variant = "fr";
      };

      console.keyMap = "fr_CH";
    };
}
