{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/gpu-nvidia.nix — NVIDIA example (ALTERNATIVE, not imported).
# =============================================================================
#
# rocinante is AMD, so this file is NOT in modules/nixos/default.nix's imports.
# It's kept as a teaching reference for an NVIDIA machine. To use it: add
# `./gpu-nvidia.nix` to the imports in modules/nixos/default.nix and remove
# `./gpu-amd.nix`.
#
# NVIDIA on Wayland/Hyprland differs from AMD in three ways worth learning:
#   1. It uses a PROPRIETARY driver (unfree) — allowUnfree must be true.
#   2. You must opt into `modesetting` for Wayland to work at all.
#   3. Newer GPUs prefer the `open` kernel modules.
let
  cfg = config.rocinante;
in
lib.mkIf (cfg.graphical.enable && false) {
  # ^ `&& false` keeps this inert even if accidentally imported. Remove the
  #   `&& false` when you genuinely switch a machine to NVIDIA.

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/Proton
  };

  hardware.nvidia = {
    modesetting.enable = true; # REQUIRED for Wayland
    open = true; # open kernel modules (Turing+; set false for very old GPUs)
    nvidiaSettings = true; # the nvidia-settings GUI
    powerManagement.enable = false; # enable if you hit suspend/resume issues
    # package = config.boot.kernelPackages.nvidiaPackages.stable; # or .beta
  };

  # If your cursor becomes invisible on Wayland, this env var is the classic fix:
  # environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
}
