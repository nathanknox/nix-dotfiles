{
  config,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/dual-boot.nix — NixOS side of a NixOS + Omarchy dual-boot.
# =============================================================================
#
# Guarded by `fleet.dualBoot.enable` (default false). This is the LINUX<->LINUX
# case, which is the friendliest dual-boot there is: both NixOS and Omarchy are
# Hyprland/Wayland Linux sharing kernel, filesystems, the Mesa/RADV GPU stack,
# and gaming tooling. The whole game is disk layout. See the vault note
# "Dual-booting NixOS and Omarchy on rocinante" for the full write-up.
#
# Recommended layout on rocinante (2x WD SN7100 2TB NVMe):
#
#   nvme0 (2TB) -- NixOS          nvme1 (2TB) -- Omarchy + shared data
#     ESP #1 (systemd-boot)          ESP #2 (Omarchy's bootloader)
#     /  (this system)               /  (Omarchy root)
#                                    /data  (SHARED: Steam, ROMs, media, music)
#
# SAFETY BY DESIGN: even with `fleet.dualBoot.enable = true`, this module does
# nothing destructive. The two things that depend on real hardware IDs — the
# shared /data mount and the systemd-boot entry that chainloads Omarchy — are
# kept COMMENTED below. They only take effect once you uncomment them and fill
# in the real device UUIDs from the installed machine. So flipping the toggle
# on today is safe; it just leaves clear, ready-to-activate templates.
let
  cfg = config.fleet;
in
lib.mkIf cfg.dualBoot.enable {

  # ---------------------------------------------------------------------------
  # 1) Shared /data partition (games/media/music), owned by neither OS.
  # ---------------------------------------------------------------------------
  # Data-driven from fleet.dualBoot.{dataDevice,dataFsType,dataMountPoint}, but
  # only mounted when you supply a real dataDevice AND uncomment the block. The
  # assertion below stops a half-configured mount from silently doing nothing.
  #
  # To activate:
  #   1. Find the UUID:  `lsblk -f`  or  `blkid`
  #   2. Set in hosts/rocinante/default.nix:
  #        fleet.dualBoot.dataDevice = "/dev/disk/by-uuid/<uuid>";
  #        fleet.dualBoot.dataFsType = "ext4";   # or "btrfs"
  #   3. Uncomment the fileSystems block below.
  #
  # fileSystems.${cfg.dualBoot.dataMountPoint} = {
  #   device = cfg.dualBoot.dataDevice;
  #   fsType = cfg.dualBoot.dataFsType;
  #   # `nofail` = don't drop to emergency shell if the disk is missing;
  #   # `x-systemd.device-timeout` bounds the wait. Good hygiene for a
  #   # secondary data disk on a machine you sometimes boot into Omarchy.
  #   options = [
  #     "nofail"
  #     "x-systemd.device-timeout=10s"
  #   ];
  # };
  #
  # Then point apps at it (on BOTH OSes): Steam -> Add Library Folder ->
  # ${cfg.dualBoot.dataMountPoint}/steam ; Jellyfin/Navidrome -> .../media ;
  # RetroArch -> .../roms. Share the LIBRARY, keep Steam CLIENT config per-OS
  # (a simultaneously-shared ~/.steam can squabble over shader caches).

  # A gentle guardrail: if you turned the mount on (uncommented it) you almost
  # certainly want a real device. This assertion is harmless while the mount is
  # commented (dataDevice can stay null); it just documents intent. Flip the
  # `false &&` to `true &&` if you want it enforced once you go live.
  assertions = [
    {
      assertion = (false && cfg.dualBoot.dataDevice == null) -> false;
      message = "fleet.dualBoot: set fleet.dualBoot.dataDevice before enabling the /data mount.";
    }
  ];

  # ---------------------------------------------------------------------------
  # 2) Bootloader: let NixOS's systemd-boot be the primary menu.
  # ---------------------------------------------------------------------------
  # With one OS per disk, the simplest reliable path is to pick the boot disk
  # from the MSI UEFI menu (F11). Cleaner is to let NixOS systemd-boot (already
  # enabled in hosts/rocinante/configuration.nix) present an Omarchy entry.
  #
  # OPTION A — keep more old generations visible for easy rollback (safe to
  # enable now; not device-specific):
  #
  # boot.loader.systemd-boot.configurationLimit = 20;
  #
  # OPTION B — an explicit extra boot entry that chainloads Omarchy's EFI stub
  # on the OTHER disk. Fill in the real EFI path once Omarchy is installed and
  # you can see its loader under the mounted ESP. Kept commented because a wrong
  # path yields a dead menu entry.
  #
  # boot.loader.systemd-boot.extraEntries = {
  #   "omarchy.conf" = ''
  #     title   Omarchy (Arch)
  #     # Point at Omarchy's bootloader EFI on nvme1's ESP. Example for a
  #     # systemd-boot/GRUB stub — adjust to what Omarchy actually installs:
  #     efi     /EFI/omarchy/grubx64.efi
  #   '';
  # };
  #
  # If instead you want the reverse (Omarchy's bootloader primary, chainloading
  # NixOS), do nothing here and configure it from Omarchy's side.
}
