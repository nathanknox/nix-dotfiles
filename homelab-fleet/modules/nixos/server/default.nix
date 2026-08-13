{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/server/default.nix — headless server services (tycho).
# =============================================================================
#
# Guarded by `rocinante.server.enable`. This is the "minimal" server per the
# plan: ONE media service (Jellyfin) is ACTIVE, plus Tailscale for private
# remote access. Everything heavier (Navidrome, Immich, containers, Samba) is
# present but commented in the sibling files so you can turn them on one at a
# time and learn each.
#
# tycho hardware context (MINISFORUM MS-01, Intel i9 + Iris Xe iGPU):
#   The iGPU is used NOT for display (headless) but for hardware video
#   transcoding in Jellyfin via VAAPI/QSV. That's the interesting teaching bit:
#   a headless box still benefits from its integrated graphics.
let
  cfg = config.fleet;
in
{
  # `imports` MUST be unconditional — you cannot place it inside a `lib.mkIf`
  # (imports are resolved before `config` values are evaluated). Each sibling
  # module self-guards on `rocinante.server.enable`, so importing them here is
  # safe and inert on non-server hosts.
  imports = [
    ./media.nix # Navidrome/Immich examples (commented)
    ./virtualization.nix # podman/libvirt (commented)
    ./networking.nix # samba/static-net (commented) + tailscale (active)
  ];

  # Only the actual configuration values are conditional.
  config = lib.mkIf cfg.server.enable {
    # -------------------------------------------------------------------------
    # Intel iGPU for hardware transcoding (VAAPI/QSV). Enables the media stack
    # to offload video decode/encode to the Iris Xe instead of pegging the CPU.
    # -------------------------------------------------------------------------
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # iHD VAAPI driver for modern Intel (Gen9+)
        vpl-gpu-rt # oneVPL runtime for QuickSync (QSV)
      ];
    };
    # Point VAAPI at the modern iHD driver.
    environment.variables.LIBVA_DRIVER_NAME = "iHD";

    # -------------------------------------------------------------------------
    # Jellyfin — the one ACTIVE media service. Serves music/photos/video over
    # the network. openFirewall punches its default ports (8096/8920).
    # -------------------------------------------------------------------------
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      # Runs as the `jellyfin` user by default. Point it at your media by placing
      # files where the jellyfin user can read them (e.g. a mount from the second
      # NVMe — see the commented data-disk mount in hosts/tycho/hardware-configuration.nix).
    };
    # The jellyfin service user needs GPU access for hardware transcoding.
    users.users.jellyfin.extraGroups = [
      "render"
      "video"
    ];

    # A couple of headless-server niceties.
    environment.systemPackages = with pkgs; [
      htop
      tmux
      ncdu # disk usage explorer — useful on a media box
    ];
  };
}
