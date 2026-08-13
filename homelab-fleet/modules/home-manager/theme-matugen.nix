{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:
# =============================================================================
# modules/home-manager/theme-matugen.nix — ROUTE B: Material-You (saneaspect).
# =============================================================================
#
# This is the SECONDARY theming style, kept in its own file and NOT imported by
# default (see the commented import in modules/home-manager/default.nix). It
# implements saneaspect's signature approach: generate a Material-You palette
# from your WALLPAPER using `matugen`, then feed those colors to waybar/swaync/
# hyprland. The result changes with the wallpaper — very different from the
# curated static registry of Route A.
#
# ------------------------------------------------------------------------------
# HOW TO SWITCH FROM ROUTE A (static) TO ROUTE B (matugen):
#   1. flake.nix: uncomment the `matugen` input.
#   2. modules/home-manager/default.nix: uncomment `./theme-matugen.nix` in
#      imports (and, if you like, comment `./theme.nix` — though leaving the
#      GTK/cursor scaffolding on is harmless).
#   3. In your host (hosts/rocinante/default.nix): set
#         rocinante.theme.matugen.enable = true;
#         rocinante.theme.wallpaper = ./path/to/wallpaper.jpg;   # REQUIRED
#   4. Rebuild. matugen runs at activation to render color templates.
# ------------------------------------------------------------------------------
#
# This module self-guards on BOTH graphical.enable AND theme.matugen.enable so
# that merely importing it does nothing until you flip the option.
let
  os = osConfig.fleet;
in
lib.mkIf (os.graphical.enable && os.theme.matugen.enable) {
  # The matugen CLI (from the flake input). Uncomment the input in flake.nix
  # first, or this reference will error.
  home.packages = [
    # inputs.matugen.packages.${pkgs.system}.default
    pkgs.swaynotificationcenter # swaync — the notification center saneaspect themes
  ];

  # matugen configuration: which templates to render and where to write them.
  # Templates use matugen's {{colors.*}} syntax. Here we render a waybar CSS and
  # a hyprland colors file from the wallpaper-derived palette.
  #
  # We keep the matugen config + templates under dotfiles/matugen/ (plaintext,
  # like the hypr dotfiles) and point matugen at them. This block writes the
  # matugen config to the XDG path.
  #
  # xdg.configFile."matugen/config.toml".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/code/nix-dotfiles/homelab-fleet/dotfiles/matugen/config.toml";

  # Run matugen at home-manager activation to (re)generate colors from the
  # current wallpaper. Guarded so it only runs when a wallpaper is set.
  #
  # home.activation.matugen = lib.mkIf (os.theme.wallpaper != null)
  #   (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     ${inputs.matugen.packages.${pkgs.system}.default}/bin/matugen image \
  #       ${builtins.toString os.theme.wallpaper} || true
  #   '');

  # NOTE: The concrete matugen templates live in dotfiles/matugen/ as plaintext
  # so you can iterate on them without a rebuild (same philosophy as the hypr
  # dotfiles). See dotfiles/matugen/config.toml and the template files there.
  #
  # Everything above is commented at the statement level too, so this module is
  # a safe, valid no-op until you complete the switch checklist and start
  # uncommenting. This keeps the default build (Route A) clean and buildable
  # without adding the matugen input.
}
