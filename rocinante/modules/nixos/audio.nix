{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
# =============================================================================
# modules/nixos/audio.nix — the pro-audio stack (opt-in).
# =============================================================================
#
# Guarded by `rocinante.audio.enable`. This is the 2026 "modern, well-supported"
# Linux pro-audio baseline:
#   * PipeWire as the server, with the JACK layer on (so JACK-native pro apps
#     like Ardour "just work" alongside normal desktop audio).
#   * Low-latency PipeWire tuning via drop-in config.
#   * musnix for the realtime plumbing (PAM rtprio/memlock limits, udev rules,
#     performance governor, plugin path env vars), with the PREEMPT_RT kernel
#     left as a separate, off-by-default toggle.
#
# rocinante's AMD RX 9070 XT is a plus here: no proprietary GPU driver to fight
# with the realtime/low-latency setup.
#
# The DAW + plugins + patchbay (user-facing apps) are installed on the home side
# in modules/home-manager/audio.nix, also gated on this toggle.
#
# musnix is imported unconditionally (its module is inert unless
# `musnix.enable = true`, which we only set inside the guard below). `imports`
# cannot live inside a `lib.mkIf`, so it is at the top level here.
let
  cfg = config.fleet;
in
{
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  config = lib.mkIf cfg.audio.enable {
    # -------------------------------------------------------------------------
    # PipeWire with the JACK layer. The base PipeWire/pulse/alsa enablement is
    # in modules/nixos/graphical.nix for the desktop; here we ensure it's on and
    # add the JACK layer + realtime scheduling. Using mkDefault/lib.mkForce-free
    # settings that merge cleanly with graphical.nix.
    # -------------------------------------------------------------------------
    security.rtkit.enable = true; # let PipeWire request the realtime scheduler
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true; # THE pro-audio bit: expose the JACK API via PipeWire

      # Low-latency tuning. 48kHz, small quantum. If you get crackles (underruns)
      # raise the quantum (e.g. 64/128/256) until stable — every rig differs.
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 64;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 256;
        };
      };
    };

    # -------------------------------------------------------------------------
    # musnix: realtime plumbing. `musnix.enable` sets PAM limits (@audio rtprio
    # 99 / memlock unlimited), udev rules (rtc/hpet/cpu_dma_latency -> audio
    # group), the performance CPU governor, vm.swappiness=10, and plugin path
    # env vars (LV2_PATH, VST3_PATH, CLAP paths, ...).
    # -------------------------------------------------------------------------
    musnix.enable = true;

    # Optional PCI latency-timer tuning for a PCI(e) sound card. Find the ID with
    # `lspci | grep -i audio` and set it here (not needed for USB interfaces):
    # musnix.soundcardPciId = "00:1f.3";

    # PREEMPT_RT realtime kernel — separate toggle, OFF by default. It rebuilds
    # the kernel and can interact with GPU/gaming. On kernels >= 6.12 musnix uses
    # mainline PREEMPT_RT (no out-of-tree patch); we point it at the latest
    # mainline so RDNA4 support stays fresh. Enable only if you measure a need.
    musnix.kernel.realtime = cfg.audio.realtimeKernel;
    musnix.kernel.packages = lib.mkIf cfg.audio.realtimeKernel pkgs.linuxPackages_latest;

    # rtcqs: a CLI that analyzes the system and suggests audio-readiness fixes.
    musnix.rtcqs.enable = true;

    # Put the primary user in the `audio` group so the musnix PAM/udev realtime
    # privileges apply to them.
    users.users.${cfg.user.name}.extraGroups = [ "audio" ];
  };
}
