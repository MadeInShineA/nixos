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
        onShutdown = "shutdown";
        onBoot = "ignore";
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;

      # libvirt uses its own nftables table, but the NixOS firewall still drops
      # DHCP/DNS from guests on the NAT bridge unless the interface is trusted
      networking.firewall.trustedInterfaces = [ "virbr0" ];

      # Whonix 18 Gateway uses passt (user-mode networking)
      systemd.services.libvirtd.path = [ pkgs.passt ];
    };

}
