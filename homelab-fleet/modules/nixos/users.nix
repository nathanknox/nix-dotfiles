{
  config,
  pkgs,
  lib,
  ...
}:
# =============================================================================
# modules/nixos/users.nix — declare the primary user from rocinante.user.*
# =============================================================================
#
# This is the vimjoyer "main-user" pattern: rather than hardcoding a username,
# we read it from our option schema so the whole config is parameterized by
# `rocinante.user.name`. Change the option in one place and the user, home
# directory, and home-manager wiring all follow.
let
  cfg = config.fleet;
in
{
  # Zsh is our login shell (configured in detail via home-manager). It must be
  # enabled at the system level too so it's a valid /etc/shells entry.
  programs.zsh.enable = true;

  users.users.${cfg.user.name} = {
    isNormalUser = true;
    description = cfg.user.fullName;
    shell = pkgs.zsh;

    # `wheel` = sudo. `networkmanager` = manage Wi-Fi/VPN without root.
    # Graphical/gaming/server groups are added conditionally below so a headless
    # box doesn't carry desktop groups it doesn't need.
    extraGroups = [
      "wheel"
      "networkmanager"
    ]
    ++ lib.optionals cfg.graphical.enable [
      "video"
      "input"
      "render"
    ]
    ++ lib.optionals cfg.server.enable [ "docker" ]; # harmless if docker off; group still declared by virt module when enabled

    # First-boot convenience ONLY. Set a real password with `passwd` after
    # first login, then you can remove this. Never commit real secrets.
    initialPassword = "changeme";

    # Add your SSH public key(s) here for key-based login (core.nix disables
    # password SSH by default). Example:
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
  };

  # Wire this user's home-manager configuration. Because the flake imported
  # `home-manager.nixosModules.home-manager`, this attribute exists. We point
  # the user's home at the HM aggregator, which then fans out to per-app
  # modules. This is the single line that connects the system half to the
  # home half of the config.
  home-manager.users.${cfg.user.name} = import ../home-manager;

  # Allow members of `wheel` to run sudo. (Default true, but explicit for the
  # teaching value: this is where privilege is granted.)
  security.sudo.wheelNeedsPassword = true;
}
