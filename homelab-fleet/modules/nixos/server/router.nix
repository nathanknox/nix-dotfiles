{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/server/router.nix — the declarative router (Rung 3a, INERT).
# =============================================================================
#
# This is the "graduate tycho into the actual router" endgame from the
# networking guide (Nate's Vault/Homelab Networking Guide.md → "router as code
# ladder"). It turns the MS-01 into a VLAN router/firewall/DHCP server, entirely
# in Nix:
#
#   VLANs   -> systemd-networkd (netdevs + networks)
#   Firewall-> nftables (stateful; the 'ct state established,related' rule is
#              what makes cameras effectively one-way)
#   DHCP    -> kea, one subnet4 per VLAN, advertising Pi-hole as DNS
#
# STATUS: OFF by default (`fleet.server.router.enable`). Even when enabled, the
# BODY below is COMMENTED — flipping the toggle alone does nothing until you
# fill in your real NIC MACs and uncomment. This is deliberate: a wrong router
# config severs the network. The ACTIVE router today is the GL.iNet Flint 3,
# whose config lives as versioned UCI under `flint/`.
#
# WHY keep an inert module at all? Same reason as gpu-nvidia.nix and
# dual-boot.nix in this repo: it documents the design fork in-tree, ready to
# flip, without affecting current builds. It also keeps the full worked example
# next to the code it belongs with.
#
# PRE-REQS before you ever enable this:
#   * tycho needs TWO usable NICs: one to the ISP modem (WAN), one trunk to the
#     managed switch carrying all VLANs. The MS-01's dual SFP+ + 2.5G ports fit.
#   * You provide Wi-Fi separately (Deco/Omada APs) — this box has no radios.
#   * A Pi-hole (or dnsmasq) reachable at 10.0.20.53 for the advertised DNS.
#   * Validate with the scan playbook in Nate's Vault/Network Reconnaissance.md.
#
# Primary sources:
#   systemd-networkd VLANs : https://wiki.nixos.org/wiki/Systemd/networkd#VLAN
#   nftables home router   : https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router
#   NixOS kea options      : https://search.nixos.org/options?query=services.kea
let
  cfg = config.fleet;

  # Reference VLAN plan (kept here as data so the commented body can map over it).
  # Matches flint/ and the vault guide.
  vlans = {
    trusted = {
      id = 10;
      net = "10.0.10";
    };
    servers = {
      id = 20;
      net = "10.0.20";
    };
    iot = {
      id = 30;
      net = "10.0.30";
    };
    cameras = {
      id = 40;
      net = "10.0.40";
    };
    guest = {
      id = 50;
      net = "10.0.50";
    };
  };
in
{
  config = lib.mkIf (cfg.server.enable && cfg.server.router.enable) {

    # -------------------------------------------------------------------------
    # A loud, deliberate reminder. Enabling the toggle compiles this assertion;
    # it forces you to come read this file and uncomment the real config rather
    # than silently half-configuring a router. Delete it once you've filled in
    # the body below.
    # -------------------------------------------------------------------------
    assertions = [
      {
        assertion = false;
        message = ''
          fleet.server.router.enable is ON but modules/nixos/server/router.nix
          is still a scaffold. Fill in your real NIC MACs, uncomment the
          systemd-networkd / nftables / kea blocks, then remove this assertion.
          The Flint 3 (flint/) is the active router until you do.
        '';
      }
    ];

    # === UNCOMMENT AND FILL IN FROM HERE ====================================

    # Route between interfaces.
    # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # Take Wi-Fi/desktop network management out of the way — a router uses
    # networkd, not NetworkManager (which core.nix enables).
    # networking.networkmanager.enable = lib.mkForce false;

    # systemd.network = {
    #   enable = true;
    #
    #   # --- Stable interface names via MAC match (edit MACs to your NICs) ---
    #   links = {
    #     "10-wan"   = { matchConfig.MACAddress = "aa:bb:cc:dd:ee:01"; linkConfig.Name = "wan"; };
    #     "10-trunk" = { matchConfig.MACAddress = "aa:bb:cc:dd:ee:02"; linkConfig.Name = "trunk"; };
    #   };
    #
    #   # --- One VLAN netdev per VLAN, stacked on the trunk NIC ---
    #   netdevs = lib.mapAttrs' (name: v: {
    #     name = "20-${name}";
    #     value = {
    #       netdevConfig = { Kind = "vlan"; Name = name; };
    #       vlanConfig.Id = v.id;
    #     };
    #   }) vlans;
    #
    #   networks = {
    #     # WAN: DHCP from the ISP/modem.
    #     "30-wan" = {
    #       matchConfig.Name = "wan";
    #       networkConfig = { DHCP = "ipv4"; IPv6AcceptRA = true; };
    #       linkConfig.RequiredForOnline = "routable";
    #     };
    #     # Trunk carries no IP; it just tags the VLANs onto the wire.
    #     "30-trunk" = {
    #       matchConfig.Name = "trunk";
    #       vlan = builtins.attrNames vlans;
    #       networkConfig.LinkLocalAddressing = "no";
    #       linkConfig.RequiredForOnline = "carrier";
    #     };
    #   }
    #   # Each VLAN interface = the router's gateway IP on that subnet.
    #   // lib.mapAttrs' (name: v: {
    #     name = "40-${name}";
    #     value = {
    #       matchConfig.Name = name;
    #       address = [ "${v.net}.1/24" ];
    #       networkConfig.ConfigureWithoutCarrier = true;
    #     };
    #   }) vlans;
    # };

    # --- Firewall: default-deny between zones, stateful allow-holes ----------
    # networking.firewall.enable = false;   # let nftables own it
    # networking.nftables = {
    #   enable = true;
    #   ruleset = ''
    #     table inet filter {
    #       chain input {
    #         type filter hook input priority 0; policy drop;
    #         iif "lo" accept
    #         ct state established,related accept
    #         iifname { "trusted", "servers" } tcp dport 22 accept
    #         iifname { "trusted","servers","iot","cameras","guest" } udp dport { 53, 67 } accept
    #         iifname { "trusted","servers","iot","cameras","guest" } tcp dport 53 accept
    #         icmp type echo-request accept
    #       }
    #       chain forward {
    #         type filter hook forward priority 0; policy drop;
    #         ct state established,related accept          # <- the 'one-way' magic
    #         iifname { "trusted","servers","iot","guest" } oifname "wan" accept
    #         iifname "trusted" oifname { "servers","iot","cameras" } accept
    #         iifname "servers" oifname "cameras" tcp dport { 554, 8554 } accept
    #         iifname "servers" oifname "iot" accept
    #         # cameras have NO forward rule -> cannot initiate anywhere.
    #       }
    #       chain output { type filter hook output priority 0; policy accept; }
    #     }
    #     table ip nat {
    #       chain postrouting {
    #         type nat hook postrouting priority 100; policy accept;
    #         oifname "wan" masquerade
    #       }
    #     }
    #   '';
    # };

    # --- DHCP (kea): one subnet per VLAN, Pi-hole as DNS ---------------------
    # services.kea.dhcp4 = {
    #   enable = true;
    #   settings = {
    #     interfaces-config.interfaces = builtins.attrNames vlans;
    #     subnet4 = lib.mapAttrsToList (name: v: {
    #       subnet = "${v.net}.0/24";
    #       pools = [ { pool = "${v.net}.50 - ${v.net}.200"; } ];
    #       option-data = [
    #         { name = "routers"; data = "${v.net}.1"; }
    #         { name = "domain-name-servers"; data = "10.0.20.53"; }  # Pi-hole
    #       ];
    #     }) vlans;
    #   };
    # };

    # === TO HERE ============================================================
  };
}
