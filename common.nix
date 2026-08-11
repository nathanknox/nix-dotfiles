{
  config,
  pkgs,
  lib,
  ...
}:

{

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.bat
    pkgs.tree
    pkgs.ripgrep
    pkgs.nil
    pkgs.statix
    pkgs.glow
    pkgs.skate
    pkgs.httpie
    pkgs.nodejs_24
    pkgs.semantic-release
    pkgs.eza

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".claude/keybindings.json".source = ./dotfiles/claude/keybindings.json;
    ".config/wtf/config.yml".source = ./dotfiles/wtf/config.yml;
  };

  # Symlink the trowel project's .claude/memory directory into the Claude Code
  # project memory location so memory files are version-controlled in the repo
  # while remaining writable at runtime.
  home.activation.claudeTrowelMemory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    memory_target="$HOME/code/trowel/.claude/memory"
    memory_link="$HOME/.claude/projects/-Users-nathan-knox-code-trowel/memory"
    mkdir -p "$memory_target"
    mkdir -p "$(dirname "$memory_link")"
    if [ ! -L "$memory_link" ]; then
      rm -rf "$memory_link"
      ln -s "$memory_target" "$memory_link"
    fi
  '';

  # ucode - Databricks' agent bootstrapper, https://github.com/databricks/ucode
  #
  # WARNING: do not add `pkgs.ucode` to home.packages. That nixpkgs attribute is
  # jow-/ucode, an unrelated JavaScript-like templating language whose binary is
  # also named `ucode`, so it would shadow this tool.
  #
  # Databricks ucode is not packaged in nixpkgs. It is a uv tool installed from
  # git through the Databricks PyPI proxy. This mirrors the install recorded in
  # ~/.local/share/uv/tools/ucode/uv-receipt.toml so the tool is declared here
  # instead of existing only as ambient machine state. Idempotent: it installs
  # only when absent. Upgrade explicitly with `uv tool upgrade ucode`.
  home.activation.ucode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.uv}/bin/uv tool list 2>/dev/null | grep -q '^ucode '; then
      # The source is a git ref, so uv shells out to `git`. Activation scripts
      # run with a minimal PATH that does not include it, and without this the
      # install fails with "Git executable not found".
      PATH="${pkgs.git}/bin:$PATH" \
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install \
          --index-url https://pypi-proxy.cloud.databricks.com/simple/ \
          "git+https://github.com/databricks/ucode"
    fi
  '';

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nknox/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    # Pin gh's config dir to the real ~/.config/gh. gh honors XDG_CONFIG_HOME,
    # but ucode/opencode redirect XDG_CONFIG_HOME to ~/.ucode/opencode-xdg for
    # their children, which makes gh look in the wrong place and appear logged
    # out. Setting GH_CONFIG_DIR explicitly overrides that everywhere.
    GH_CONFIG_DIR = "${config.home.homeDirectory}/.config/gh";
  };

  # `uv tool install` places entrypoints in ~/.local/bin (ucode, claude, ...),
  # but nothing put that directory on PATH — not /etc/paths, not /etc/paths.d,
  # not .zprofile/.zshenv, not this config. A clean login shell (for example a
  # new tmux window) therefore could not find `ucode`. sessionPath writes it
  # into hm-session-vars.sh, which every login shell sources.
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # My packages:
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = false;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
  programs.broot = {
    enable = true;
    settings.modal = false;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.git = {
    enable = true;
    settings.user.name = "Nathan Knox";
    settings.user.email = "nathan.knox@gmail.com";
  };
  # jujutsu (jj) - git-compatible VCS, used colocated in git repos.
  # Home Manager writes ~/.config/jj/config.toml from these settings.
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Nathan Knox";
      user.email = "nathan.knox@gmail.com";
      ui.editor = "nvim";
    };
  };
  programs.gh = {
    enable = true;
  };
  programs.gitui = {
    enable = true;
  };
  programs.helix = {
    enable = false;
    defaultEditor = true;
    extraPackages = [
      pkgs.marksman
      pkgs.nil
    ];
  };
  programs.lazygit = {
    enable = true;
  };
  programs.neovim = {
    enable = true;

    # home-manager flipped both defaults from `true` to `false` in 26.05.
    # `home.stateVersion = "23.11"` would still select the legacy `true`, so
    # these are set explicitly: it adopts the new default, silences the
    # deprecation warnings, and drops the Ruby and Python remote-provider
    # closures. LazyVim does not use either provider.
    withRuby = false;
    withPython3 = false;

    # home-manager generates ~/.config/nvim/init.lua (provider wiring), which
    # would otherwise replace the LazyVim bootstrap that used to live in the
    # hand-written init.lua. Re-add the bootstrap here so LazyVim still loads;
    # everything it reads (lua/config/lazy.lua, lua/plugins/, lazy-lock.json)
    # stays unmanaged on disk.
    #
    # `initLua` is the current name; it was `extraLuaConfig` before.
    initLua = ''
      require("config.lazy")
    '';
  };
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
  # OpenCode TUI: drop ctrl+b/ctrl+f/ctrl+a/ctrl+e from input keybinds so they
  # don't collide with the tmux prefix (ctrl+b) or shell readline. Arrows and
  # Home/End keep the same behavior, so no functionality is lost.
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
  # OpenCode global skills. Sourced from the repo so they are version-controlled
  # and reproducible across machines. The caveman skill is a communication mode;
  # see dotfiles/opencode/skills/caveman/SKILL.md for its behavior and triggers.
  # recursive = true symlinks each file individually, leaving the skills/
  # directory itself writable so opencode can drop in ad-hoc skills alongside.
  xdg.configFile."opencode/skills/caveman" = {
    source = ./dotfiles/opencode/skills/caveman;
    recursive = true;
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    extraConfig = ''
      source-file ~/code/nix-config/tmux.conf
    '';
  };

  programs.uv = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  programs.zellij.enable = true;

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
    };

    # home-manager now manages ~/.zprofile as well as ~/.zshenv, so the
    # hand-written .zprofile had to move in here or it would be clobbered.
    # `brew shellenv` matters most: it is the only thing putting
    # /opt/homebrew/bin on PATH.
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Visual Studio Code CLI (`code`)
      export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

      # opencode shell completions. Guarded because compdef only exists once
      # compinit has run, and .zprofile is also sourced by non-interactive
      # login shells, where it previously errored with "command not found:
      # compdef".
      if typeset -f compdef > /dev/null; then
        _opencode_yargs_completions()
        {
          local reply
          local si=$IFS
          IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "''${words[@]}"))
          IFS=$si
          if [[ ''${#reply} -gt 0 ]]; then
            _describe 'values' reply
          else
            _default
          fi
        }
        compdef _opencode_yargs_completions opencode
      fi
    '';
    initContent = ''
      export PATH=$PATH:/Users/nathan.knox/.pulumi/bin

      # Belt-and-braces for home.sessionPath. A long-lived tmux server exports
      # __HM_SESS_VARS_SOURCED=1, which makes .zshenv skip hm-session-vars.sh in
      # every new window, so ~/.local/bin (uv tool entrypoints: ucode, claude)
      # would still be missing there. .zshrc runs regardless of that guard, so
      # re-add it here. The case test keeps PATH free of duplicates.
      case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
      esac
    '';
  };
}
