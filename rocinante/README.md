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
| **omarchy / omarchy-nix** | curated static theme **registry** (`themes/`) + opinionated `options.rocinante.*` schema. |
| **saneaspect** | Material-You (**matugen**) "wallpaper drives the palette" route + rounded "island" Waybar look — kept in separate files, enabled by one uncomment. |

## Layout

```
flake.nix              inputs, both hosts, devShell, formatter
modules/
  options.nix          the rocinante.* option schema (types + docs)
  nixos/               system modules (core, users, graphical, gpu-amd, gaming, server/)
  home-manager/        user modules (core, shell, git, hyprland, waybar, wofi, terminal, theme[, theme-matugen])
themes/                static base16 registry (tokyo-night default, everforest, gruvbox)
dotfiles/hypr/         plaintext, hot-editable Hyprland config (colors.conf is generated)
dotfiles/matugen/      Route B (matugen) templates, inert until enabled
hosts/{rocinante,tycho}/  per-machine entrypoint + configuration + hardware placeholder
```

## Bring-up (fresh install)

Hardware discovery has **not** been run yet, so each host ships a
`hardware-configuration.nix` that intentionally `throw`s. Replace it on install:

```bash
# 1. Boot the NixOS minimal ISO on the target machine.
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
   `rocinante.theme.name`). *Route B (separate files):* saneaspect matugen
   Material-You — see the switch checklist at the top of
   `modules/home-manager/theme-matugen.nix`.
4. **Login** — *active:* SDDM (pairs with saneaspect's `vitreous` theme).
   *commented:* greeter-less `uwsm` autologin (see `graphical.nix` +
   `shell.nix`).
5. **GPU** — *active:* `gpu-amd.nix` (RDNA4). *commented example:*
   `gpu-nvidia.nix`.

## nixpkgs channel note (RDNA4)

The flake tracks **`nixos-unstable`** on purpose: the RX 9070 XT (RDNA4) is new
and wants a recent kernel + Mesa. If a rebuild ever shows no display / no
Vulkan / stale Mesa, either `nix flake update` or uncomment
`boot.kernelPackages = pkgs.linuxPackages_latest;` in `modules/nixos/gpu-amd.nix`.

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
to `rocinante/`, authored as `nathan.knox@gmail.com`.
