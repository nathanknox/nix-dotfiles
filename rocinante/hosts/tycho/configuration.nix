{ config, pkgs, ... }:
# =============================================================================
# hosts/tycho/configuration.nix — machine-specific settings for the server.
# =============================================================================
#
# Hardware context (from Home Lab notes): MINISFORUM MS-01, Intel Core i9,
# Intel Iris Xe iGPU (used for Jellyfin hardware transcode, see server module),
# 2x ~2TB NVMe, dual 10GbE SFP+. Headless.
{
  networking.hostName = "tycho";

  # MS-01 is UEFI.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Headless: no need to wait on network-online for a display, but DO make sure
  # sshd is reachable early. openssh is enabled in modules/nixos/core.nix.
  #
  # For a server you often want to allow password auth OFF (default in core.nix)
  # and rely on keys — add your key in modules/nixos/users.nix authorizedKeys.

  system.stateVersion = "25.05";
}
