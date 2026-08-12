{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/gpu-amd.nix — AMD Radeon RX 9070 XT (RDNA4) — ACTIVE for rocinante.
# =============================================================================
#
# rocinante's GPU is an AMD RX 9070 XT (RDNA4). AMD on Linux uses the in-kernel
# `amdgpu` driver + Mesa (RADV Vulkan) — there is NO proprietary driver to
# install, which is a big reason AMD is pleasant for Linux gaming.
#
# Guarded behind a small local toggle derived from the AMD choice: we only
# apply this when the host opts into graphics AND leaves the AMD path active.
# (There's no dedicated option for GPU vendor to keep the schema barebones;
# instead you pick a GPU module by editing the imports in
# modules/nixos/default.nix. This module self-guards on graphical.enable so it
# is inert on the headless server.)
#
# IMPORTANT — RDNA4 freshness:
#   RDNA4 is very new. It needs a recent kernel and recent Mesa. We track
#   nixos-unstable in flake.nix specifically for this. If after a rebuild you
#   see missing display output, no Vulkan, or a very old Mesa, bump the kernel
#   to the latest by uncommenting `boot.kernelPackages` below and/or run
#   `nix flake update` to pull a newer nixpkgs.
let
  cfg = config.rocinante;
in
lib.mkIf cfg.graphical.enable {
  # Load amdgpu early (KMS) for a clean, flicker-free boot and proper Wayland.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # OPTIONAL: force the newest kernel if the default is too old for RDNA4.
  # Uncomment if you hit RDNA4 issues on first boot.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # The modern graphics stack. `enable32Bit` is REQUIRED for Steam/Proton and
  # many games (they ship 32-bit libraries).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # RADV (Mesa Vulkan) is included via mesa; add extra userspace bits here.
    extraPackages = with pkgs; [
      amdvlk # AMD's open Vulkan driver, as a fallback alongside RADV
      # RADV (from mesa) is the default and usually preferred for gaming.
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };

  # Prefer RADV over amdvlk at runtime (RADV generally performs better for
  # gaming). Apps can override with AMD_VULKAN_ICD if needed.
  environment.variables.AMD_VULKAN_ICD = "RADV";

  # Useful AMD tools for monitoring/tuning while gaming.
  environment.systemPackages = with pkgs; [
    radeontop # GPU utilization TUI
    # lact     # GUI for fan/clock/power tuning (uncomment if you want it)
  ];

  # X server video driver hint. Harmless under pure Wayland; helps XWayland and
  # any X fallback pick amdgpu.
  services.xserver.videoDrivers = [ "amdgpu" ];
}
