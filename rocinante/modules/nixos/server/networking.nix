{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/server/networking.nix — server networking.
# =============================================================================
#
# Tailscale is ACTIVE (private mesh VPN: reach tycho from anywhere without
# exposing ports to the internet — matches your Home Lab notes). Samba and
# static/systemd-networkd addressing are COMMENTED examples.
lib.mkIf config.rocinante.server.enable {
  # --- Tailscale (ACTIVE): zero-config private access to the server ----------
  # After first boot, run `sudo tailscale up` once to authenticate. The MS-01
  # then joins your tailnet and is reachable by its Tailscale name/IP.
  services.tailscale.enable = true;

  # --- Samba (COMMENTED): SMB file shares for the LAN (NAS-style) ------------
  # From your Home Lab NAS interest. Uncomment and define shares to serve the
  # media disk to other machines on the network.
  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     media = {
  #       path = "/srv/media";
  #       browseable = "yes";
  #       "read only" = "yes";
  #       "guest ok" = "yes";
  #     };
  #   };
  # };

  # --- Static addressing (COMMENTED): the MS-01 has dual 10GbE SFP+ ----------
  # For a server you often want a stable IP. NetworkManager (from core.nix) can
  # do this, or switch to systemd-networkd for a fully declarative approach:
  # networking.networkmanager.enable = lib.mkForce false;
  # systemd.network = {
  #   enable = true;
  #   networks."10-lan" = {
  #     matchConfig.Name = "enp*";       # match the MS-01's NICs
  #     networkConfig.DHCP = "no";
  #     address = [ "192.168.1.10/24" ];
  #     routes = [ { Gateway = "192.168.1.1"; } ];
  #   };
  # };
}
