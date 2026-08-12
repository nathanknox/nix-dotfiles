{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
# =============================================================================
# hosts/tycho/hardware-configuration.nix — PRE-FILLED TEMPLATE (all commented).
# =============================================================================
#
# Hardware discovery has NOT been run yet, so the ENTIRE config below is
# commented out and this file evaluates to an empty module ({}). Run real
# discovery on the MS-01 before a switch.
#
# The commented body is pre-filled from the Home Lab specs for tycho:
#   * Box  : MINISFORUM MS-01
#   * CPU  : Intel Core i9                     -> kvm-intel
#   * iGPU : Intel Iris Xe (headless transcode -> modules/nixos/server/default.nix VAAPI/QSV)
#   * Disk : 2x ~2TB NVMe                       -> nvme initrd module
#   * NIC  : dual 10GbE SFP+ (+ 2x 2.5GbE)
#
# HOW TO USE ON INSTALL:
#   1. Boot the NixOS minimal ISO; partition, format, mount at /mnt (+ /mnt/boot).
#   2. Run:  sudo nixos-generate-config --root /mnt
#   3. EITHER copy the generated file over this one, OR uncomment the block
#      below and paste in the real UUIDs.
#   4. Replace every REPLACE-ME-* UUID with your actual values.
#
# =============================================================================
# {
#   imports = [
#     (modulesPath + "/installer/scan/not-detected.nix")
#   ];
#
#   # --- Boot / initrd -------------------------------------------------------
#   # The MS-01 boots from NVMe and has Thunderbolt/USB4; `thunderbolt` is
#   # commonly present. nixos-generate-config will confirm the exact set.
#   boot.initrd.availableKernelModules = [
#     "xhci_pci"
#     "nvme"          # the 2x NVMe drives
#     "usbhid"
#     "usb_storage"
#     "sd_mod"
#     "thunderbolt"   # MS-01 has TB4/USB4
#   ];
#   boot.initrd.kernelModules = [ ];
#   boot.kernelModules = [ "kvm-intel" ];   # Intel Core i9 virtualization (VMs/containers)
#   boot.extraModulePackages = [ ];
#
#   # --- Filesystems ---------------------------------------------------------
#   # PRIMARY NVMe: OS root. Replace UUID with the real one.
#   fileSystems."/" = {
#     device = "/dev/disk/by-uuid/REPLACE-ME-ROOT-UUID";
#     fsType = "ext4";
#   };
#
#   # EFI System Partition (MS-01 is UEFI; systemd-boot mounts it at /boot).
#   fileSystems."/boot" = {
#     device = "/dev/disk/by-uuid/REPLACE-ME-ESP-UUID";
#     fsType = "vfat";
#     options = [ "fmask=0077" "dmask=0077" ];
#   };
#
#   # SECOND NVMe as the MEDIA data disk. Jellyfin (and the commented
#   # Navidrome/Immich) read from here. Uncomment + set UUID. Consider btrfs/ZFS
#   # for snapshots, or a mirror across both NVMe for resilience.
#   # fileSystems."/srv/media" = {
#   #   device = "/dev/disk/by-uuid/REPLACE-ME-MEDIA-UUID";
#   #   fsType = "ext4";
#   # };
#
#   # swapDevices = [ ];
#
#   # --- Networking ----------------------------------------------------------
#   # MS-01 has 2x 10GbE SFP+ and 2x 2.5GbE. DHCP-by-default via NetworkManager
#   # (core.nix). For a stable server IP, see the commented static/systemd-networkd
#   # block in modules/nixos/server/networking.nix.
#   networking.useDHCP = lib.mkDefault true;
#
#   # --- Platform / microcode ------------------------------------------------
#   nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
#   hardware.cpu.intel.updateMicrocode =
#     lib.mkDefault config.hardware.enableRedistributableFirmware;
# }
#
# =============================================================================
# Until the above is filled in and uncommented, this module contributes nothing:
{
}
