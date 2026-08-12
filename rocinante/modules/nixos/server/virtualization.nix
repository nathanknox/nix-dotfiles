{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/server/virtualization.nix — containers & VMs (COMMENTED).
# =============================================================================
#
# From your Home Lab notes: tycho should host VMs/containers. Here are the two
# common NixOS routes, both off by default. Pick one (or both) and uncomment.
lib.mkIf config.rocinante.server.enable {
  # --- Containers: Podman (rootless, docker-compatible) ----------------------
  # Podman is the usual NixOS default (daemonless, rootless-friendly). The
  # `dockerCompat` alias makes `docker ...` commands work.
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };
  # # If you prefer Docker proper instead of Podman:
  # # virtualisation.docker.enable = true;

  # --- Virtual machines: libvirt/QEMU/KVM ------------------------------------
  # The MS-01's i9 supports VT-x/KVM. This gives you full VMs (e.g. a macOS or
  # Windows guest, other Linux distros) managed with virt-manager.
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # # Add your user to the libvirtd group (do this in users.nix extraGroups):
  # #   extraGroups = [ ... "libvirtd" ];

  # --- MicroVMs / declarative VMs --------------------------------------------
  # For fully declarative, Nix-defined VMs, look at the `microvm.nix` flake.
  # Left as a pointer to keep inputs minimal here.
}
