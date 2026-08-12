{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/server/media.nix — extra media services (ALL COMMENTED).
# =============================================================================
#
# The plan calls for a MINIMAL server: Jellyfin only (in server/default.nix).
# These are the obvious next additions from your Home Lab notes — kept off so
# you enable them deliberately. Uncomment a block, `nixos-rebuild switch`, done.
lib.mkIf config.rocinante.server.enable {
  # --- Navidrome: lightweight music streaming server (Subsonic API) ----------
  # Great pairing with Jellyfin if you want a dedicated music experience.
  # services.navidrome = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     MusicFolder = "/srv/media/music";
  #   };
  # };

  # --- Immich: self-hosted photo & video backup (Google Photos alternative) --
  # Immich is heavier (Postgres + Redis + ML). Uncomment when ready.
  # services.immich = {
  #   enable = true;
  #   openFirewall = true;
  #   mediaLocation = "/srv/media/photos";
  #   # Uses a local postgres + redis by default in recent nixpkgs.
  # };

  # --- Nextcloud: files/calendar/contacts ------------------------------------
  # services.nextcloud = {
  #   enable = true;
  #   hostName = "tycho.local";
  #   config.adminpassFile = "/run/secrets/nextcloud-admin"; # use a real secret
  # };

  # Placeholder so this module is valid when everything above is commented.
  # (An empty `lib.mkIf ... {}` is fine; this comment documents why.)
}
