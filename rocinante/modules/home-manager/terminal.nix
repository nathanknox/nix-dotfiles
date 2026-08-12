{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/terminal.nix — terminal emulator.
# =============================================================================
#
# DEFAULT (ACTIVE): kitty (matches your existing setup; $terminal in Hyprland).
# ALTERNATIVES (COMMENTED): foot (tonybanters) and alacritty (saneaspect).
# Colors from the theme registry so the terminal matches the desktop.
let
  os = osConfig.rocinante;
  themes = import ../../themes;
  t = themes.${os.theme.name};
  c = h: "#${h}";
in
lib.mkIf os.graphical.enable {
  programs.kitty = {
    enable = true;
    font = {
      name = os.fonts.mono;
      size = os.fonts.sizePt;
    };
    settings = {
      background = c t.base00;
      foreground = c t.base05;
      selection_background = c t.base02;
      cursor = c t.accent;
      # A minimal, readable set. kitty maps color0..15; we set the essentials.
      color0 = c t.base00;
      color1 = c t.base08; # red
      color2 = c t.base0B; # green
      color3 = c t.base0A; # yellow
      color4 = c t.base0D; # blue
      color5 = c t.base0E; # magenta
      color6 = c t.base0C; # cyan
      color7 = c t.base05; # fg
      background_opacity = "0.95";
      confirm_os_window_close = 0;
    };
  };

  # --- ALTERNATIVE: foot (tonybanters), COMMENTED ---------------------------
  # programs.foot = {
  #   enable = true;
  #   settings = {
  #     main.font = "${os.fonts.mono}:size=${builtins.toString os.fonts.sizePt}";
  #     colors = {
  #       background = t.base00;
  #       foreground = t.base05;
  #     };
  #   };
  # };

  # --- ALTERNATIVE: alacritty (saneaspect), COMMENTED -----------------------
  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     font.normal.family = os.fonts.mono;
  #     font.size = os.fonts.sizePt;
  #     colors.primary.background = c t.base00;
  #     colors.primary.foreground = c t.base05;
  #   };
  # };
}
