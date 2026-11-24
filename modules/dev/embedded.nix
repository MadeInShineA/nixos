# Embedded development: USB access to debug probes without sudo
# (micro:bit v2 for the rust-embedded Discovery MB2 book, via probe-rs / cargo-embed)
{
  flake.modules.nixos.embedded =
    { pkgs, ... }:
    {
      # Must sort before 73-seat-late.rules for TAG+="uaccess" to work,
      # so it can't go in services.udev.extraRules (which ends up in 99-local.rules)
      services.udev.packages = [
        (pkgs.writeTextDir "lib/udev/rules.d/69-microbit.rules" ''
          # CMSIS-DAP for microbit
          SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", TAG+="uaccess"
        '')
      ];
    };
}
