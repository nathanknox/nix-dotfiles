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
lib.mkIf config.fleet.server.enable {
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
  # The MS-01's i9 supports VT-x/KVM. libvirt (managed via virt-manager) runs
  # QEMU/KVM guests: other Linux distros and Windows work out of the box.
  #
  # macOS guests are a special case: plain virt-manager will NOT boot macOS. It
  # requires the community OpenCore recipe (e.g. OSX-KVM / Docker-OSX) AND runs
  # afoul of Apple's EULA, which only permits virtualizing macOS on Apple
  # hardware — so it's not supported on the MS-01. For legitimate macOS VMs use
  # an Apple-Silicon Mac with Tart, UTM, or VirtualBuddy instead.
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # # Add your user to the libvirtd group (do this in users.nix extraGroups):
  # #   extraGroups = [ ... "libvirtd" ];

  # --- MicroVMs / declarative VMs --------------------------------------------
  # For fully declarative, Nix-defined VMs, look at the `microvm.nix` flake.
  # Left as a pointer to keep inputs minimal here.
}
