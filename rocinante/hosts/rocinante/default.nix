{ config, pkgs, ... }:
# =============================================================================
# hosts/rocinante/default.nix — the DESKTOP host entrypoint.
# =============================================================================
#
# A host's job is small and declarative: import the shared module set, import
# this machine's hardware + base system config, then set `rocinante.*` options
# to describe what THIS machine is. All the behavior lives in the shared
# modules; the host just flips toggles and fills in identity.
{
  imports = [
    ../../modules/nixos # shared system module set (self-guarding by toggle)
    ./configuration.nix # hostname, timezone, bootloader, stateVersion
    ./hardware-configuration.nix # generated per-machine (placeholder until you run nixos-generate-config)
  ];

  # --- Describe this machine via the shared option schema --------------------
  rocinante = {
    user = {
      name = "nknox";
      fullName = "Nathan Knox";
      email = "nathan.knox@gmail.com";
    };

    # rocinante is the all-in-one desktop: graphical + gaming ON, server OFF.
    graphical.enable = true;
    gaming.enable = true;
    server.enable = false;

    # Theming — ROUTE A (static base16), the active default.
    theme.name = "tokyo-night"; # try "everforest" or "gruvbox"
    # To switch to ROUTE B (matugen Material-You), set the following AND
    # uncomment ./theme-matugen.nix in modules/home-manager/default.nix and the
    # matugen input in flake.nix:
    # theme.matugen.enable = true;
    # theme.wallpaper = ./wallpaper.jpg;   # required for matugen

    fonts.mono = "JetBrainsMono Nerd Font";
    fonts.sizePt = 11;

    # Monitors: empty = auto-detect on first boot. Set your real layout here
    # once known (Hyprland `monitor=` value without the leading keyword), e.g.:
    # monitors = [ "DP-1,2560x1440@144,0x0,1" ];
    monitors = [ ];
  };
}
