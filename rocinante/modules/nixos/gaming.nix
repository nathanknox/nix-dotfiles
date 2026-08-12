{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/gaming.nix — Steam + gamescope + gamemode (opt-in).
# =============================================================================
#
# Guarded by `rocinante.gaming.enable`. On rocinante (AMD RX 9070 XT) this is a
# smooth path: no proprietary drivers, and the graphics stack's `enable32Bit`
# (set in gpu-amd.nix) is exactly what Steam needs.
#
# This is deliberately a compact, opinionated gaming baseline. Fancier setups
# (a full Steam Deck-like gamescope session, Proton-GE, MangoHud overlays,
# low-latency kernels) are noted as commented extras so you can grow into them.
let
  cfg = config.rocinante;
in
lib.mkIf cfg.gaming.enable {
  # Steam. `gamescopeSession` gives you a Steam Big Picture-style session you
  # can select at login — handy for a couch/gaming mode.
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play
    dedicatedServer.openFirewall = false;
  };

  # gamescope: a micro-compositor for games (better fullscreen, scaling, FSR).
  programs.gamescope = {
    enable = true;
    capSysNice = true; # allow gamescope to raise its scheduling priority
  };

  # GameMode: temporarily applies performance tweaks (CPU governor, etc.) while
  # a game runs. Launch a game with `gamemoderun %command%` in Steam options.
  programs.gamemode.enable = true;

  # Handy gaming userland.
  environment.systemPackages = with pkgs; [
    mangohud # in-game FPS/perf overlay (add `mangohud %command%` in Steam)
    protonup-qt # manage Proton-GE versions
    # lutris        # non-Steam game launcher
    # heroic        # Epic/GOG launcher
  ];

  # OPTIONAL: Proton-GE tools path. Point Steam at custom compat tools you
  # install with protonup-qt. Uncomment and adjust to your user.
  # environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
  #   "/home/${cfg.user.name}/.steam/root/compatibilitytools.d";

  # OPTIONAL: a low-latency / gaming-tuned kernel. The CachyOS kernel is popular
  # for gaming. Requires adding the chaotic/cachyos input; left as a pointer.
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;
}
