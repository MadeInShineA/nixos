# No keyring daemon (gnome-keyring), even if another module enables it
{
  flake.modules.nixos.no-keyring =
    { lib, ... }:
    {
      services.gnome.gnome-keyring.enable = false;
      security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
      security.pam.services.cosmic-greeter.enableGnomeKeyring = lib.mkForce false;
    };
}
