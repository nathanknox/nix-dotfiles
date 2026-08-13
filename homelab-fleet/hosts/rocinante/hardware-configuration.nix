{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
# =============================================================================
# hosts/rocinante/hardware-configuration.nix — PRE-FILLED TEMPLATE (all commented).
# =============================================================================
#
# Hardware discovery has NOT been run yet, so the ENTIRE config below is
# commented out and this file evaluates to an empty module ({}). That keeps the
# flake buildable-to-the-point-of-hardware while forcing you to run real
# discovery before a switch.
#
# The commented body is pre-filled from the Home Lab specs for rocinante:
#   * CPU  : Intel Core Ultra 7 270K (Arrow Lake-S, LGA1851)  -> kvm-intel
#   * Mobo : MSI Z890 Tomahawk WiFi (UEFI)                    -> systemd-boot + ESP
#   * RAM  : 32GB DDR5-6000
#   * Disk : 2x WD SN7100 2TB NVMe                            -> nvme initrd module
#   * GPU  : AMD Radeon RX 9070 XT (RDNA4)                    -> see modules/nixos/gpu-amd.nix
#
# HOW TO USE ON INSTALL:
#   1. Boot the NixOS minimal ISO; partition, format, mount at /mnt (+ /mnt/boot).
#   2. Run:  sudo nixos-generate-config --root /mnt
#   3. EITHER copy the generated file over this one, OR uncomment the block
#      below and paste in the real UUIDs from `blkid` / the generated file.
#   4. The device UUIDs are placeholders (REPLACE-ME-*) — they MUST be filled in
#      with your actual values or the system won't boot.
#
# =============================================================================
# {
#   imports = [
#     (modulesPath + "/installer/scan/not-detected.nix")
#   ];
#
#   # --- Boot / initrd -------------------------------------------------------
#   # Typical modules for an NVMe + USB UEFI desktop. nixos-generate-config will
#   # tailor this to exactly what it detects; this is the expected shape.
#   boot.initrd.availableKernelModules = [
#     "xhci_pci"      # USB 3 controller
#     "ahci"          # SATA (if any spinning/SATA SSD is attached)
#     "nvme"          # the WD SN7100 NVMe drives
#     "usbhid"        # USB keyboards/mice at boot (LUKS passphrase entry, etc.)
#     "usb_storage"
#     "sd_mod"
#   ];
#   boot.initrd.kernelModules = [ ];
#   boot.kernelModules = [ "kvm-intel" ];   # Intel Core Ultra 7 270K virtualization
#   boot.extraModulePackages = [ ];
#
#   # --- Filesystems ---------------------------------------------------------
#   # PRIMARY NVMe (WD SN7100 #1): root. Replace the UUID with your real one
#   # (`blkid` or the generated hardware file). ext4 shown; btrfs is a fine
#   # alternative if you want subvolumes/snapshots.
#   fileSystems."/" = {
#     device = "/dev/disk/by-uuid/REPLACE-ME-ROOT-UUID";
#     fsType = "ext4";
#   };
#
#   # EFI System Partition (FAT32) on the primary disk. MSI Z890 is UEFI, and
#   # configuration.nix uses systemd-boot, which mounts the ESP at /boot.
#   fileSystems."/boot" = {
#     device = "/dev/disk/by-uuid/REPLACE-ME-ESP-UUID";
#     fsType = "vfat";
#     options = [ "fmask=0077" "dmask=0077" ];
#   };
#
#   # OPTIONAL: SECOND NVMe (WD SN7100 #2) as a data/games mount. Uncomment and
#   # set its UUID. ext4 shown; consider btrfs/ZFS, or a two-disk mirror.
#   # fileSystems."/data" = {
#   #   device = "/dev/disk/by-uuid/REPLACE-ME-DATA-UUID";
#   #   fsType = "ext4";
#   # };
#
#   # Swap: none by default (32GB RAM). Add a swapfile or zram if you want
#   # hibernation or a safety margin:
#   # swapDevices = [ ];
#   # zramSwap.enable = true;
#
#   # --- Networking (scaffolded by the generator) ----------------------------
#   # The Z890 Tomahawk has 2.5GbE + Intel Wi-Fi. DHCP-by-default is fine; we use
#   # NetworkManager (modules/nixos/core.nix), so leave per-interface DHCP off
#   # unless you switch to scripted networking.
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
