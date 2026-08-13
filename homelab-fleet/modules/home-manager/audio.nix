{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/audio.nix — DAW + plugins + patchbay (user apps).
# =============================================================================
#
# The system half (PipeWire-JACK, musnix realtime) is in modules/nixos/audio.nix.
# This installs the user-facing pro-audio applications, gated on the same
# `rocinante.audio.enable` toggle so it's inert unless you opt in.
let
  os = osConfig.fleet;
in
lib.mkIf os.audio.enable {
  home.packages = with pkgs; [
    # --- DAW (pick your main; Ardour is the open-source flagship) ------------
    ardour # full open-source DAW, JACK/PipeWire-native
    # reaper       # commercial, native Linux, hugely popular (uncomment to use)
    # bitwig-studio# commercial, first-class native Linux build

    # --- Patchbay / routing (PipeWire-native) --------------------------------
    qpwgraph # the modern PipeWire patchbay (visualize/route JACK+Pulse graph)
    # helvum       # alternative PipeWire patchbay
    # qjackctl     # classic JACK control GUI (works via pipewire-jack)

    # --- Plugins (LV2 modern standard; CLAP is the newer open format) --------
    # A small, high-quality starter set — expand to taste.
    x42-plugins # pro LV2 meters/utilities (Ardour author)
    lsp-plugins # large, high-quality LV2/VST/CLAP suite
    calf # classic LV2 effects rack
    # Distros expose big meta-groups; on Nix just add the plugin packages you want.

    # --- Utilities -----------------------------------------------------------
    jack_example_clients # jack_delay etc. for round-trip latency measurement
  ];
}
