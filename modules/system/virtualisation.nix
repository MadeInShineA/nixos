{
  flake.modules.nixos.virtualisation =
    { pkgs, ... }:
    {
      # Podman (+ distrobox)
      virtualisation.podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;
        # Required for containers under podman-compose to be able to talk to each other
        defaultNetwork.settings.dns_enabled = true;
      };

      # Make Kind work with podman
      systemd.settings.Manager.DefaultDelegate = "yes";

      environment.systemPackages = with pkgs; [
        podman-compose
        distrobox
      ];

      # Libvirt + virt-manager
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;
    };
}
