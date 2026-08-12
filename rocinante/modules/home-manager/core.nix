{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/home-manager/core.nix — user-facing CLI tooling (all hosts).
# =============================================================================
#
# This is where "the tools you like" live (per your Nix notes: bat, ripgrep,
# eza, fzf, ...). Putting them in home-manager (not system packages) means they
# follow YOU across machines and are managed per-user. Applies to both the
# desktop and the headless server, so you get a comfortable shell over SSH too.
{
  home.packages = with pkgs; [
    # Modern replacements for classic tools
    bat # cat with syntax highlighting
    eza # ls with icons/tree
    ripgrep # fast grep (rg)
    fd # fast find
    fzf # fuzzy finder
    zoxide # smarter cd (z)
    du-dust # du, but nicer (dust)
    jq # JSON processor
    tree
    htop
    btop # prettier system monitor

    # From your existing common.nix defaults (portable, non-macOS bits):
    glow # render markdown in the terminal
    httpie # friendly HTTP client
    nodejs_24 # node runtime (semantic-release, tooling)
    semantic-release # release automation

    # Nix ergonomics
    nil # Nix LSP (editor support)
    nixfmt-rfc-style # formatter
    statix # Nix linter
  ];

  # A few programs are better enabled as home-manager *programs* (they wire
  # shell integration for you) rather than bare packages.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # fast, caching direnv for Nix flakes/devShells
  };
  programs.eza = {
    enable = true;
    enableZshIntegration = true; # sets ls aliases to eza
    icons = "auto";
    git = true;
  };

  # --- Folded in from your existing common.nix (portable defaults) -----------
  # File manager: yazi, with the `y` wrapper that cd's to the last dir on exit.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };
  # broot: interactive tree navigator (non-modal, matching your setting).
  programs.broot = {
    enable = true;
    settings.modal = false;
  };
  # zellij: terminal workspace multiplexer (you enable it alongside tmux).
  programs.zellij.enable = true;
  # uv: fast Python package/tool manager.
  programs.uv.enable = true;

  # Neovim: LazyVim-style. home-manager generates init.lua; we re-add the
  # LazyVim bootstrap so a hand-managed lua/ config on disk still loads. This
  # mirrors your common.nix neovim block (withRuby/withPython3 = false to drop
  # the legacy remote-provider closures LazyVim doesn't use).
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    # `initLua` is the current name (was `extraLuaConfig`). LazyVim reads
    # lua/config/lazy.lua etc. from ~/.config/nvim, left unmanaged on disk.
    initLua = ''
      require("config.lazy")
    '';
  };

  # Scala LSP plugin spec for LazyVim (nvim-metals), as in your common.nix.
  xdg.configFile."nvim/lua/plugins/scala.lua".text = ''
    return {
      {
        "scalameta/nvim-metals",
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
      },
    }
  '';

  # OpenCode TUI keybinds: drop ctrl+b/f/a/e from input keybinds so they don't
  # collide with the tmux prefix (ctrl+b) or shell readline. From common.nix.
  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    keybinds = {
      input_move_left = "left";
      input_move_right = "right";
      input_line_home = "home";
      input_line_end = "end";
      input_word_forward = "alt+right,alt+f";
      input_word_backward = "alt+left,alt+b";
    };
  };
  # NOTE: your common.nix also vendors opencode skills (caveman, smart-brevify)
  # from ./dotfiles/opencode/skills. Those live in the PARENT nix-dotfiles flake
  # and are intentionally not referenced here so rocinante/ stays a
  # self-contained flake (a flake can only read files under its own root). If
  # you want them here too, copy dotfiles/opencode/skills into rocinante/ and
  # add an xdg.configFile."opencode/skills/<name>" = { source = ...; recursive = true; }.
}
