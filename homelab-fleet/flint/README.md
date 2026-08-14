# flint/ — GL.iNet Flint 3 (BE9300) router config, versioned (Rung 2)

The Flint 3 is the fleet's **router / firewall / DHCP / DNS-forwarder** and runs
GL.iNet's OpenWrt fork — it is **not** a NixOS host, so its "config as code" story
is *OpenWrt UCI text files under version control*, not a `nixosConfiguration`.

This directory is the **Rung 2** step from the networking guide
(`Nate's Vault/Homelab Networking Guide.md` → "router as code ladder"):

    Rung 0  stock GL.iNet web UI            (click-ops, day one)
    Rung 1  edit /etc/config/* over SSH     (real OpenWrt/UCI)
    Rung 2  those files live HERE, in git   (reproducible, rollback-able)   <-- this dir
    Rung 3  a fully declarative router in NixOS on tycho  (see modules/nixos/server/router.nix)

## Layout

    flint/etc/config/network      VLANs (10/20/30/40/50) + per-VLAN L3 interfaces
    flint/etc/config/dhcp         one DHCP pool per VLAN, hands out Pi-hole as DNS
    flint/etc/config/wireless     SSID -> VLAN mapping (the Flint's edge over Deco)
    flint/etc/config/firewall     zones + default-deny between VLANs + allow-holes

These mirror the paths on the router (`/etc/config/*`). They are **templates** —
MAC addresses, Wi-Fi keys (`CHANGE_ME`), and the exact port/bridge device names
(`br-lan`, `lan1`..`lan4`) depend on your unit and firmware. Read the comments.

## Pull the live config down (first time)

    ssh root@192.168.8.1 'tar czf - /etc/config' > flint-live.tgz
    # inspect, then reconcile with the templates here

## Push a change up

    scp flint/etc/config/network  root@192.168.8.1:/etc/config/network
    scp flint/etc/config/firewall root@192.168.8.1:/etc/config/firewall
    # ... then on the router:
    ssh root@192.168.8.1 'reload_config && /etc/init.d/firewall restart'

## Verify segmentation after any change

See the scan playbook in `Nate's Vault/Network Reconnaissance.md`
(nmap from inside each VLAN) and the quick cheatsheet in
`Nate's Vault/Homelab VLAN & Nix Reference.md`.

## Reference VLAN plan

| VLAN | Name    | Subnet         | Gateway     |
| ---- | ------- | -------------- | ----------- |
| 10   | trusted | 10.0.10.0/24   | 10.0.10.1   |
| 20   | servers | 10.0.20.0/24   | 10.0.20.1   |
| 30   | iot     | 10.0.30.0/24   | 10.0.30.1   |
| 40   | cameras | 10.0.40.0/24   | 10.0.40.1   |
| 50   | guest   | 10.0.50.0/24   | 10.0.50.1   |

Primary docs: <https://openwrt.org/docs/guide-user/base-system/uci> ·
<https://docs.gl-inet.com/router/en/4/>
