{ config, pkgs, ... }:
# =============================================================================
# hosts/rocinante/configuration.nix — machine-specific system settings.
# =============================================================================
#
# Only things that are genuinely per-machine live here: hostname, bootloader,
# timezone, and stateVersion. Everything reusable is in modules/nixos/.
#
# Hardware context (from Home Lab notes): Intel Core Ultra 7 270K (Arrow Lake,
# LGA1851), MSI Z890 Tomahawk WiFi (UEFI), 32GB DDR5-6000, 2x WD SN7100 2TB
# NVMe, AMD RX 9070 XT. The CPU/GPU/NVMe specifics are wired in
# hardware-configuration.nix + modules/nixos/gpu-amd.nix.
{
  networking.hostName = "rocinante";

  # UEFI systemd-boot (MSI Z890 is UEFI). Simple, fast, no GRUB needed.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

  # Intel CPU microcode updates (Arrow Lake). Redistributable firmware is
  # pulled in by the hardware scan; this enables the microcode update path.
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # This is the NixOS release this machine was first installed from. Set it to
  # the installer's version and then DO NOT change it (it governs stateful data
  # defaults). Using 26.05 to match the NixOS 26.05 install media.
  system.stateVersion = "26.05";
}
