# =============================================================================
# themes/default.nix — the static theme REGISTRY (Route A, omarchy-style).
# =============================================================================
#
# A theme here is just an attrset of colors + a little metadata. Keeping themes
# as plain data (not tied to any one app) is the omarchy idea: one palette, many
# consumers (Hyprland, Waybar, wofi, kitty, GTK). Each app module reads the
# active palette and renders it into that app's own config format.
#
# Palettes use the base16 convention (base00..base0F):
#   base00 background      base03 comments/dim     base06 light fg
#   base01 lighter bg      base04 dark fg           base07 lightest fg
#   base02 selection bg    base05 default fg
#   base08 red   base09 orange  base0A yellow  base0B green
#   base0C cyan  base0D blue    base0E magenta base0F brown
#
# To add a theme: create themes/<name>.nix returning this shape, then add
# "<name>" to the enum in modules/options.nix. The build validates the name, so
# a mismatch is a clear error.
{
  tokyo-night = import ./tokyo-night.nix;
  everforest = import ./everforest.nix;
  gruvbox = import ./gruvbox.nix;
}
