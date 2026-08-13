{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/default.nix — aggregator for the user's home config.
# =============================================================================
#
# `osConfig` is the NixOS system config, available because we run home-manager
# AS a NixOS module (see flake.nix Route A). We read the shared `fleet.*`
# options from it so the home side stays in sync with the system side WITHOUT
# duplicating values — e.g. the graphical toggle and the chosen theme.
let
  # System-level rocinante options (username, theme, graphical toggle, ...).
  os = osConfig.fleet;
in
{
  imports = [
    ./core.nix # cross-platform CLI tooling (always on)
    ./shell.nix # zsh + prompt + aliases
    ./git.nix # git + jujutsu, identity from options

    # --- Desktop-only home modules -------------------------------------------
    # These are always imported but self-guard on the graphical toggle, so on
    # tycho they contribute nothing.
    ./theme.nix # ROUTE A (ACTIVE): static base16 -> GTK/cursor + palette export
    ./hyprland.nix # symlinks plaintext Hyprland dotfiles (hot-editable)
    ./waybar.nix # status bar (omarchy-clean default; island variant commented)
    ./wofi.nix # application launcher
    ./terminal.nix # kitty (default), foot/alacritty commented
    ./audio.nix # DAW/plugins/patchbay (guarded by rocinante.audio.enable)

    # --- ROUTE B (saneaspect Material-You), COMMENTED --------------------------
    # Uncomment this ONE import to switch theming from the static base16 route
    # to matugen's wallpaper-derived Material-You palette. Also set
    # `rocinante.theme.matugen.enable = true` and a wallpaper in your host.
    # See the file header for the full switch checklist.
    # ./theme-matugen.nix
  ];

  # Home-manager needs to know who/where it is managing. Derive from the shared
  # options so there is a single source of truth.
  home.username = os.user.name;
  home.homeDirectory = "/home/${os.user.name}";

  # The home-manager release your config targets. Keep in sync with the system
  # stateVersion philosophy: set once, change deliberately after reading release
  # notes. Using a current value since this is a fresh config.
  home.stateVersion = "26.05";

  # Let home-manager manage itself (so `home-manager` the tool is available and
  # the news/version machinery works).
  programs.home-manager.enable = true;
}
