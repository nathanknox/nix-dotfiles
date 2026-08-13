{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
# =============================================================================
# modules/home-manager/git.nix — git + jujutsu (jj), identity from options.
# =============================================================================
#
# Both VCS tools read identity from the shared `rocinante.user.*` options so
# your name/email are defined once. jj is your primary VCS (colocated in git
# repos); git is configured too for interop and tools that expect it.
let
  os = osConfig.fleet;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = os.user.fullName;
      user.email = os.user.email;
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # jujutsu (jj): git-compatible VCS. Home-manager writes ~/.config/jj/config.toml.
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = os.user.fullName;
      user.email = os.user.email;
      ui.editor = "nvim";
    };
  };

  # git TUIs you use (from common.nix): lazygit + gitui.
  programs.lazygit.enable = true;
  programs.gitui.enable = true;
  programs.gh.enable = true; # GitHub CLI
}
