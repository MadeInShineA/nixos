{
  flake.modules.nixos.locale = {
    time.timeZone = "Europe/Zurich";
    i18n.defaultLocale = "en_US.UTF-8";

    # Swiss French keyboard everywhere (X11, wayland compositors, tty)
    services.xserver.xkb = {
      layout = "ch";
      variant = "fr";
    };
    console.keyMap = "fr_CH";

    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "ch";
      XKB_DEFAULT_VARIANT = "fr";
      XKB_DEFAULT_OPTIONS = "terminate:ctrl_alt_bksp";
    };
  };
}
