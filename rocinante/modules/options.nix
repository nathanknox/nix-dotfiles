{ lib, ... }:
# =============================================================================
# modules/options.nix — the opinionated option schema for this config.
# =============================================================================
#
# This is the vimjoyer "custom options module" pattern and the omarchy-nix
# "one central options schema" pattern combined. Instead of scattering magic
# strings across modules, we declare a typed namespace `fleet.*` ONCE here.
# Every other module reads `config.fleet.*` and each host writes to it in
# hosts/<host>/default.nix.
#
# NAMING: the namespace is `fleet` (not `rocinante`) on purpose. `rocinante` is
# both the repo directory AND the desktop host, so naming the shared schema
# after it would wrongly imply tycho depends on the rocinante host. `fleet.*`
# reads as "settings for any machine in this fleet" — rocinante and tycho alike.
#
# WHY do this in a barebones config? Because it teaches the single most
# important NixOS module concept: the split between `options` (the schema you
# declare) and `config` (the values you set). Options give you types, defaults,
# and documentation you can introspect. Feature toggles (`graphical`, `gaming`,
# `server`) let one set of modules serve very different machines (desktop vs
# headless server) without duplication.
{
  options.fleet = {
    # --- Identity -------------------------------------------------------------
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "nknox";
        description = "Primary login user's username.";
      };
      fullName = lib.mkOption {
        type = lib.types.str;
        default = "Nathan Knox";
        description = "Primary user's full name (used by git, etc.).";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "nathan.knox@gmail.com";
        description = "Primary user's email (used by git and jujutsu).";
      };
    };

    # --- Feature toggles ------------------------------------------------------
    # These are the levers each host pulls. `mkEnableOption` creates a boolean
    # that defaults to false and renders nicely in `nixos-option`.
    graphical.enable = lib.mkEnableOption "the Hyprland graphical desktop (bar, launcher, greeter)";
    gaming.enable = lib.mkEnableOption "gaming support (Steam, gamescope, gamemode)";
    server.enable = lib.mkEnableOption "headless server services (Jellyfin, tailscale, ...)";

    # Pro-audio: PipeWire-JACK low-latency stack + musnix realtime tuning +
    # a DAW/plugins. Off by default. See modules/nixos/audio.nix.
    audio = {
      enable = lib.mkEnableOption "the pro-audio stack (PipeWire-JACK, musnix realtime tuning, Ardour)";
      realtimeKernel = lib.mkEnableOption ''
        the PREEMPT_RT realtime kernel via musnix. Off by default because it
        REBUILDS the kernel and can interact with GPU/gaming setups. On a modern
        vanilla kernel PipeWire low-latency is usually enough; enable only if you
        measure a need. On kernels >= 6.12 musnix uses mainline PREEMPT_RT (no patch).
      '';
    };

    # --- Theming --------------------------------------------------------------
    theme = {
      # ROUTE A (omarchy-style): pick a curated, static base16 scheme by name.
      # The enum is the single source of truth; adding a theme means adding a
      # file in themes/ and a name here. This is validated at build time, so a
      # typo is a clear error rather than a silent fallback.
      name = lib.mkOption {
        type = lib.types.enum [
          "tokyo-night"
          "everforest"
          "gruvbox"
        ];
        default = "tokyo-night";
        description = ''
          Active static (base16) theme. Route A / omarchy-style.
          Ignored when the matugen (Material-You) route is enabled — see
          modules/home-manager/theme-matugen.nix.
        '';
      };

      # ROUTE B (saneaspect-style): generate a Material-You palette from a
      # wallpaper via matugen. Off by default so the barebones static route is
      # what builds out of the box. Enabling it is documented in
      # modules/home-manager/theme-matugen.nix (uncomment the import).
      matugen.enable = lib.mkEnableOption "the matugen Material-You theme route (saneaspect-style)";

      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to the wallpaper. Displayed by hyprpaper, and — when
          theme.matugen.enable is true — the source image matugen extracts the
          Material-You palette from.
        '';
      };
    };

    # --- Appearance knobs -----------------------------------------------------
    fonts = {
      mono = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Monospace/terminal font family.";
      };
      sizePt = lib.mkOption {
        type = lib.types.int;
        default = 11;
        description = "Base font size in points.";
      };
    };

    # Hyprland monitor lines, verbatim. Empty default = Hyprland auto-detects
    # (good enough for first boot). On rocinante you'll likely set your real
    # monitor(s) here; the format is Hyprland's `monitor=` value.
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "DP-1,2560x1440@144,0x0,1" ];
      description = "Hyprland monitor= lines (without the leading 'monitor=').";
    };
  };
}
