{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/shell.nix — zsh + starship prompt + aliases.
# =============================================================================
let
  os = osConfig.fleet;
in
{
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins"; # vi keybindings in the shell (matches your setup)
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # eza-based ls aliases come from programs.eza; add a couple of extras.
      ll = "eza -l --git";
      la = "eza -la --git";

      # The rebuild helper (tonybanters `nrs`). Rebuilds THIS host from the
      # flake. `--flake .#<host>` picks the nixosConfiguration by hostname.
      # Run it from inside the rocinante/ directory.
      nrs = "sudo nixos-rebuild switch --flake .#${osConfig.networking.hostName}";
      # Update flake inputs (nixpkgs/home-manager) then you can `nrs`.
      nup = "nix flake update";
      # Quick edit of this config.
      conf = "cd ~/code/nix-dotfiles/rocinante && $EDITOR .";
    };

    # Belt-and-braces PATH for ~/.local/bin (uv tools, etc.), de-duplicated.
    initContent = ''
      case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
      esac
    '';

    # --- ALTERNATIVE greeter route (uwsm autologin), COMMENTED ----------------
    # If you chose greeter-less autologin instead of SDDM (see graphical.nix),
    # this is the other half: auto-start Hyprland on the first TTY at login.
    # profileExtra = lib.mkIf os.graphical.enable ''
    #   if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    #     exec uwsm start -S hyprland-uwsm.desktop
    #   fi
    # '';
  };

  # Starship prompt — fast, informative, themable. Used on every host.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # tmux — folded in from your common.nix defaults. Your common.nix sourced an
  # external ~/code/nix-config/tmux.conf; here we keep rocinante self-contained
  # by inlining the equivalent baseline via extraConfig. Add your own tweaks
  # in extraConfig (it's plain tmux.conf syntax).
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    extraConfig = ''
      # Quality-of-life defaults (mouse, truecolor, faster escape).
      set -g mouse on
      set -g default-terminal "tmux-256color"
      set -sg escape-time 10
      set -g renumber-windows on
    '';
  };

  # Session variables — folded in from common.nix (portable subset). The macOS
  # bits (GH_CONFIG_DIR workaround, brew shellenv, VS Code app PATH) are omitted
  # since this is a NixOS/Linux config.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Put ~/.local/bin (uv tool entrypoints, etc.) on PATH declaratively, matching
  # your common.nix home.sessionPath.
  home.sessionPath = [ "$HOME/.local/bin" ];
}
