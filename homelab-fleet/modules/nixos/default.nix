# =============================================================================
# modules/nixos/default.nix — aggregator for system-level (NixOS) modules.
# =============================================================================
#
# Importing this one file pulls in the whole shared NixOS module set. Each
# sub-module is guarded by a `fleet.*` feature toggle (see
# modules/options.nix), so importing everything is safe: a module does nothing
# unless its toggle is on. That is what lets `rocinante` (desktop) and `tycho`
# (headless) share the exact same import list and diverge only via options.
{
  imports = [
    ../options.nix # the fleet.* schema (must be imported once)

    ./core.nix # nix settings, networking, locale, base packages (always on)
    ./users.nix # the primary user, derived from rocinante.user.*

    ./graphical.nix # Hyprland desktop      (guarded by rocinante.graphical.enable)
    ./gaming.nix # Steam/gamescope/etc.  (guarded by rocinante.gaming.enable)
    ./audio.nix # PipeWire-JACK + musnix (guarded by rocinante.audio.enable)

    ./gpu-amd.nix # AMD RDNA4 GPU (rocinante) — ACTIVE example
    # ./gpu-nvidia.nix   # NVIDIA GPU — ALTERNATIVE example, kept commented.
    #                    # Enable this (and disable gpu-amd) on an NVIDIA box.

    ./dual-boot.nix # NixOS+Omarchy dual-boot (guarded by fleet.dualBoot.enable;
    #               # OFF by default, and device-specific bits stay commented)

    ./server # headless services  (guarded by rocinante.server.enable)
  ];
}
