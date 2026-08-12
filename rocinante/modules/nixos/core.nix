{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/core.nix — baseline system config shared by EVERY host.
# =============================================================================
#
# This is the "always on" module: things every machine needs regardless of
# whether it's a desktop or a server. Host-specific bits (hostname, timezone,
# stateVersion, bootloader details) live in hosts/<host>/configuration.nix so
# this file stays generic.
{
  # ---------------------------------------------------------------------------
  # Nix daemon settings
  # ---------------------------------------------------------------------------
  nix.settings = {
    # Flakes + the new CLI. Required for `nixos-rebuild --flake` to work.
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Deduplicate the store automatically (saves disk; safe).
    auto-optimise-store = true;
  };

  # Garbage-collect old generations weekly so /nix/store doesn't grow forever.
  # Keep the last ~2 weeks so you can still roll back to a recent generation.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Allow unfree packages (Steam, some firmware, etc.). Opinionated: on.
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # Networking (generic). Hostname is set per-host in configuration.nix.
  # ---------------------------------------------------------------------------
  # NetworkManager is the pragmatic default for both a Wi-Fi desktop
  # (rocinante: MSI Z890 has Intel Wi-Fi) and a wired server (tycho). A server
  # could instead use systemd-networkd for static addressing — see
  # modules/nixos/server/networking.nix for that note.
  networking.networkmanager.enable = true;

  # Firewall on by default; open ports where a service needs them (e.g. the
  # server module opens Jellyfin's port). Opinionated: secure by default.
  networking.firewall.enable = true;

  # ---------------------------------------------------------------------------
  # Locale / time. Timezone is per-host (configuration.nix) since a laptop may
  # travel; locale is fine to standardize here.
  # ---------------------------------------------------------------------------
  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------------
  # Base packages every machine should have at the SYSTEM level. Keep this
  # lean: user-facing CLI tooling belongs in home-manager (modules/home-manager/
  # core.nix), not here. These are "you want them even in a rescue shell" tools.
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim # a system editor that exists before home-manager activates
    git # needed by flakes to fetch inputs; useful in recovery
    wget
    curl
    pciutils # lspci — indispensable when wiring GPU/hardware
    usbutils # lsusb
  ];

  # Use the same default editor everywhere.
  environment.variables.EDITOR = "nvim";

  # Let `nix-shell -p` / comma find programs by path (quality-of-life).
  programs.command-not-found.enable = false; # off: replaced by better tools in HM

  # ---------------------------------------------------------------------------
  # OpenSSH: enabled by default. Harmless on the desktop, essential on the
  # headless server (tycho) since you administer it over the network.
  # Opinionated hardening: no root login, keys only (set your keys per-user).
  # ---------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkDefault false; # keys only; override per-host if needed
    };
  };

  # NOTE: `system.stateVersion` is intentionally NOT set here. It is a
  # per-machine value that must match the release you first installed, so it
  # lives in each hosts/<host>/configuration.nix.
}
