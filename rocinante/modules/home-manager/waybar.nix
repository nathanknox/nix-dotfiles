{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/waybar.nix — status bar.
# =============================================================================
#
# STYLE FORK (per the plan: omarchy default + saneaspect variant, separated):
#   * DEFAULT (ACTIVE): a clean, flat, omarchy-style top bar — simple modules,
#     theme colors from the registry, minimal chrome.
#   * VARIANT (COMMENTED): a saneaspect-style rounded "dynamic island" bar —
#     centered pill, rounded module groups. Uncomment the island `style` block
#     (and comment the default one) to switch looks without touching layout.
#
# Colors come from the theme registry so the bar matches the rest of the
# desktop (Route A). Under the matugen route (Route B), swap the color source
# to matugen's generated CSS (noted inline).
let
  os = osConfig.fleet;
  themes = import ../../themes;
  t = themes.${os.theme.name};

  # Helper: base16 hex (no '#') -> CSS hex.
  c = h: "#${h}";
in
lib.mkIf os.graphical.enable {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 6;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "tray"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
      };
      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };
      cpu.format = "  {usage}%";
      memory.format = "  {}%";
      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  {ipaddr}";
        format-disconnected = "睊 off";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "  muted";
        format-icons.default = [
          ""
          ""
          ""
        ];
        on-click = "pavucontrol";
      };
      tray.spacing = 8;
    };

    # --- DEFAULT (omarchy-clean) style: flat bar, theme colors ---------------
    style = ''
      * {
        font-family: "${os.fonts.mono}";
        font-size: ${builtins.toString os.fonts.sizePt}pt;
        border: none;
        border-radius: 0;
      }
      window#waybar {
        background: ${c t.base00};
        color: ${c t.base05};
      }
      #workspaces button {
        padding: 0 8px;
        color: ${c t.base04};
      }
      #workspaces button.active {
        color: ${c t.accent};
        border-bottom: 2px solid ${c t.accent};
      }
      #clock, #cpu, #memory, #network, #pulseaudio, #tray {
        padding: 0 10px;
        color: ${c t.base05};
      }
      #clock { color: ${c t.accent}; }
    '';

    # --- VARIANT (saneaspect "dynamic island") style: COMMENTED --------------
    # To use it: comment the `style` above and uncomment this one. Rounded pill
    # groups floating over a transparent bar. (Set the bar transparent by also
    # setting `background: transparent;` on window#waybar.)
    #
    # style = ''
    #   * {
    #     font-family: "${os.fonts.mono}";
    #     font-size: ${builtins.toString os.fonts.sizePt}pt;
    #     border: none;
    #   }
    #   window#waybar { background: transparent; }
    #   #workspaces, #clock, #cpu, #memory, #network, #pulseaudio, #tray {
    #     background: ${c t.base01};
    #     color: ${c t.base05};
    #     margin: 6px 4px;
    #     padding: 2px 12px;
    #     border-radius: 16px;          /* the "island" pill */
    #   }
    #   #clock {
    #     background: ${c t.accent};
    #     color: ${c t.base00};
    #     font-weight: bold;
    #   }
    #   #workspaces button.active { color: ${c t.accent}; }
    # '';
    #
    # ROUTE B (matugen) note: instead of the registry `t` colors above, you'd
    # `@import` matugen's generated colors CSS (written by theme-matugen.nix)
    # and reference its @define-color variables here.
  };
}
