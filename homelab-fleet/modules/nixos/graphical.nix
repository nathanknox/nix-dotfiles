{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/graphical.nix — the Hyprland desktop (SYSTEM half).
# =============================================================================
#
# Guarded by `fleet.graphical.enable`. On tycho (headless) this whole file
# is inert. The SYSTEM half sets up the compositor, audio, fonts, portals, and
# the login greeter. The LOOK of the desktop (bar, launcher, keybinds, theme)
# is the HOME half — see modules/home-manager/hyprland.nix and friends.
let
  cfg = config.fleet;
in
lib.mkIf cfg.graphical.enable {
  # ---------------------------------------------------------------------------
  # Hyprland compositor (system-level enablement).
  # This installs Hyprland and sets up the session so a greeter can launch it.
  # We use the nixpkgs Hyprland (tracks unstable, which we're on) rather than
  # the flake input, to keep inputs minimal and cache hits high. If you want
  # bleeding-edge Hyprland, add the hyprland flake input and set
  # `programs.hyprland.package` to it.
  # ---------------------------------------------------------------------------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # run X11 apps (Steam, many games) under Hyprland
    # withUWSM wraps the session in the Universal Wayland Session Manager, which
    # gives cleaner systemd integration for the graphical session.
    withUWSM = true;
  };

  # ---------------------------------------------------------------------------
  # Audio: PipeWire (modern replacement for PulseAudio). Standard, opinionated.
  # ---------------------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # realtime priority for low-latency audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # needed by many games/Steam
    pulse.enable = true;
    # jack.enable = true;      # uncomment if you use JACK audio software
  };

  # ---------------------------------------------------------------------------
  # Login greeter — SDDM (recommended for this config).
  #
  # WHY SDDM: it pairs naturally with the saneaspect direction you chose (their
  # `vitreous` is an SDDM theme), works well launching a Wayland Hyprland
  # session, and is a clean, teachable display-manager example.
  #
  # ALTERNATIVE (commented): greeter-less autologin via uwsm, the tonybanters
  # minimalist path. To use it instead, disable SDDM below and uncomment the
  # getty autologin + the `.profileExtra` exec in modules/home-manager/shell.nix.
  # ---------------------------------------------------------------------------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # run SDDM itself on Wayland
    # To theme SDDM like saneaspect's Material-Design greeter, install the
    # `vitreous` theme (https://github.com/saneaspect/vitreous) into
    # /run/current-system/sw/share/sddm/themes and set:
    # theme = "vitreous";
  };

  # ALTERNATIVE greeter-less autologin (uncomment to use instead of SDDM):
  # services.getty.autologinUser = cfg.user.name;

  # ---------------------------------------------------------------------------
  # XDG portals: required for screen sharing, file pickers, etc. under Wayland.
  # The Hyprland module wires the hyprland portal; add the gtk portal for the
  # widest app compatibility (file choosers in GTK apps, etc.).
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ---------------------------------------------------------------------------
  # Fonts. JetBrainsMono Nerd Font is the default (glyphs for Waybar/wofi/
  # terminal icons). Note the nixpkgs move to the per-font `nerd-fonts.*`
  # attributes (the old `nerdfonts.override { fonts = [...]; }` is deprecated).
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
  ];
  fonts.enableDefaultPackages = true;

  # A minimal set of Wayland utilities that the desktop expects to exist at the
  # system level (the polkit agent, brightness/volume helpers). App-level tools
  # (waybar, wofi, terminal) are installed via home-manager.
  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
    wl-clipboard
    libnotify
  ];

  # A graphical polkit agent so GUI apps can prompt for privilege escalation.
  security.polkit.enable = true;
}
