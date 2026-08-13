# rocinante — an opinionated, barebones, teaching NixOS + Hyprland flake

Two machines, one flake:

- **`rocinante`** — all-in-one **desktop**: development + gaming, Hyprland,
  AMD RX 9070 XT (RDNA4). This folder's name is also the hostname; it gets the
  bulk of the graphical/gaming content.
- **`tycho`** — headless **media/dev server** (MINISFORUM MS-01, Intel i9 +
  Iris Xe). No desktop; reuses the same modules with graphical/gaming off and
  server on.

This repo is written as a **teaching exercise**: heavily commented, and wherever
there's a real design fork it shows both routes (the active one uncommented, the
alternative commented right beside it).

## Inspirations (and what each contributes)

| Source | Contribution |
| --- | --- |
| **vimjoyer** | `hosts/` + `modules/{nixos,home-manager}/` layout; custom `options`/`config` module (`modules/options.nix`); per-app modules. |
| **tonybanters (tonybtw)** | home-manager wired *into* NixOS (one `nixos-rebuild`); Hyprland kept as plaintext dotfiles, symlinked with `mkOutOfStoreSymlink` for hot-editing. |
| **omarchy / omarchy-nix** | curated static theme **registry** (`themes/`) + opinionated `options.fleet.*` schema. |
| **saneaspect** | Material-You (**matugen**) "wallpaper drives the palette" route + rounded "island" Waybar look — kept in separate files, enabled by one uncomment. |

## Layout

```
flake.nix              inputs, both hosts, devShell, formatter
modules/
  options.nix          the fleet.* option schema (types + docs)
  nixos/               system modules (core, users, graphical, gpu-amd, gaming, server/)
  home-manager/        user modules (core, shell, git, hyprland, waybar, wofi, terminal, theme[, theme-matugen])
themes/                static base16 registry (tokyo-night default, everforest, gruvbox)
dotfiles/hypr/         plaintext, hot-editable Hyprland config (colors.conf is generated)
dotfiles/matugen/      Route B (matugen) templates, inert until enabled
hosts/{rocinante,tycho}/  per-machine entrypoint + configuration + hardware placeholder
```

## Getting NixOS 26.05 install media

These configs target **NixOS 26.05** (`system.stateVersion = "26.05"`). Start
from the 26.05 installer:

- **Download page (pick the release, then the ISO):**
  <https://nixos.org/download/> — choose the **26.05** minimal ISO (recommended)
  or the graphical ISO.
- **Direct release directory (resolves to the current 26.05 build):**
  <https://channels.nixos.org/nixos-26.05> — this 302-redirects to the live
  release tree (e.g. `releases.nixos.org/nixos/26.05/nixos-26.05.XXXX.<rev>/`)
  where the `nixos-minimal-*-x86_64-linux.iso` and its `.sha256` live.
- **Write it to USB:** `sudo dd if=nixos-minimal-26.05*.iso of=/dev/sdX bs=4M status=progress conv=fsync`
  (replace `/dev/sdX` with your USB device from `lsblk`), or use a tool like
  Ventoy/Rufus/balenaEtcher.
- **Verify** the download against the published SHA-256 on the download page
  before writing.

> stateVersion vs channel: `26.05` here is the *release you install from* and it
> should never change afterward. The nixpkgs *channel this flake tracks* is a
> separate choice (currently `nixos-unstable`, for RDNA4 freshness) — see
> `flake.nix` for how to pin it to `nixos-26.05` instead.

## Bring-up (fresh install)

Hardware discovery has **not** been run yet, so each host ships a
`hardware-configuration.nix` whose body is fully commented (it evaluates to an
empty module). Replace it — or uncomment + fill in real UUIDs — on install:

```bash
# 1. Boot the NixOS 26.05 minimal ISO on the target machine.
# 2. Partition, format, and mount your disks at /mnt (+ /mnt/boot for EFI).
# 3. Generate the real hardware file:
sudo nixos-generate-config --root /mnt
# 4. Get this repo onto the machine (clone your fork), then copy the generated
#    file over the placeholder, e.g. for rocinante:
cp /mnt/etc/nixos/hardware-configuration.nix hosts/rocinante/hardware-configuration.nix
# 5. Build the system (picks the nixosConfiguration by host name):
sudo nixos-rebuild switch --flake .#rocinante     # or .#tycho
```

Each placeholder file lists the *expected* generated contents for that exact
machine, so the diff is easy to sanity-check.

## Everyday commands

```bash
nrs        # alias: sudo nixos-rebuild switch --flake .#<thishost>
nup        # alias: nix flake update  (bump nixpkgs / home-manager)
nix flake check       # evaluate all configs
nix fmt               # format every .nix file (nixfmt)
nix develop           # dev shell: nil, nixfmt, statix, deadnix
```

## The design forks (where to learn by flipping a switch)

1. **home-manager wiring** — *Route A (active):* HM as a NixOS module, one
   `nixos-rebuild`. *Route B (commented in `flake.nix`):* standalone
   `home-manager switch`. 
2. **Hyprland config** — *Route 1 (active):* plaintext dotfiles symlinked with
   `mkOutOfStoreSymlink` → edit + `hyprctl reload`, no rebuild. *Route 2
   (commented in `modules/home-manager/hyprland.nix`):* fully declarative
   `wayland.windowManager.hyprland.settings`.
3. **Theming** — *Route A (active):* static base16 registry (`themes/`,
   `fleet.theme.name`). *Route B (separate files):* saneaspect matugen
   Material-You — see the switch checklist at the top of
   `modules/home-manager/theme-matugen.nix`.
4. **Login** — *active:* SDDM (pairs with saneaspect's `vitreous` theme).
   *commented:* greeter-less `uwsm` autologin (see `graphical.nix` +
   `shell.nix`).
5. **GPU** — *active:* `gpu-amd.nix` (RDNA4). *commented example:*
   `gpu-nvidia.nix`.

## Pro-audio (opt-in)

A modern Linux pro-audio stack is available behind `fleet.audio.enable`:
- **PipeWire-JACK** low-latency server (`modules/nixos/audio.nix`) — JACK-native
  apps work alongside normal desktop audio.
- **musnix** for realtime plumbing (PAM rtprio/memlock, udev rules, performance
  governor, plugin paths). The **PREEMPT_RT kernel** is a separate,
  off-by-default toggle (`fleet.audio.realtimeKernel`) since it rebuilds the
  kernel; on 6.12+ musnix uses mainline PREEMPT_RT (no patch).
- **Ardour** (+ qpwgraph patchbay, LV2/CLAP plugins) on the home side
  (`modules/home-manager/audio.nix`).

Enable it in a host with `fleet.audio.enable = true;` (rocinante's AMD GPU
has no proprietary-driver friction, so it pairs well with realtime audio).

## nixpkgs channel note (26.05 vs RDNA4)

You **install from NixOS 26.05** and pin `system.stateVersion = "26.05"`, but the
flake **tracks `nixos-unstable`** on purpose: the RX 9070 XT (RDNA4) is new and
wants a recent kernel + Mesa, which the 26.05 release channel may lag on. These
are independent choices.

If you prefer the config to follow the 26.05 release channel instead, set both
in `flake.nix`: `nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"` **and**
`home-manager.url = "github:nix-community/home-manager/release-26.05"` (they must
match), then `nix flake update`.

If a rebuild ever shows no display / no Vulkan / stale Mesa on unstable, either
`nix flake update` or uncomment `boot.kernelPackages = pkgs.linuxPackages_latest;`
in `modules/nixos/gpu-amd.nix`.

## Defaults folded in from `common.nix`

The portable home-manager defaults from the parent repo's `common.nix` are the
defaults here too: zsh (vi mode, autosuggest, syntax highlighting), starship,
tmux (vi, base-index 1, mouse/truecolor), direnv + nix-direnv, broot, yazi
(`y`), zellij, uv, lazygit + gitui + gh, the neovim LazyVim bootstrap + Scala
(nvim-metals) plugin spec, the opencode `tui.json` keybinds, `EDITOR=nvim`, and
`~/.local/bin` on PATH. macOS-only bits (brew shellenv, VS Code app path,
`GH_CONFIG_DIR`, the darwin ucode/uv activation) are intentionally omitted since
this is a Linux/NixOS config.

## Version control

This lives inside a colocated git+jj repo. Work is committed with `jj`, scoped
to `homelab-fleet/`, authored as `nathan.knox@gmail.com`.
