{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/wofi.nix — application launcher (SUPER+D).
# =============================================================================
#
# wofi is the launcher (referenced by dotfiles/hypr/keybinds.conf as $menu).
# Styled from the theme registry so it matches Waybar and Hyprland. A rounded,
# minimal popup — leans omarchy-clean, with a comment on making it more
# saneaspect-rounded.
let
  os = osConfig.rocinante;
  themes = import ../../themes;
  t = themes.${os.theme.name};
  c = h: "#${h}";
in
lib.mkIf os.graphical.enable {
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 600;
      height = 400;
      always_parse_args = true;
      show_all = false;
      prompt = "Search";
      insensitive = true;
    };
    style = ''
      * {
        font-family: "${os.fonts.mono}";
        font-size: ${builtins.toString os.fonts.sizePt}pt;
      }
      window {
        background-color: ${c t.base00};
        color: ${c t.base05};
        border: 2px solid ${c t.accent};
        border-radius: 12px;   /* bump to 20px for a rounder, saneaspect feel */
      }
      #input {
        margin: 8px;
        padding: 8px;
        background-color: ${c t.base01};
        color: ${c t.base05};
        border: none;
        border-radius: 8px;
      }
      #entry:selected {
        background-color: ${c t.accent};
        color: ${c t.base00};
        border-radius: 8px;
      }
    '';
  };
}
