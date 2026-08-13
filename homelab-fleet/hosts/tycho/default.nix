{ config, pkgs, ... }:
# =============================================================================
# hosts/tycho/default.nix — the HEADLESS SERVER host entrypoint.
# =============================================================================
#
# tycho reuses the EXACT same shared module set as rocinante. The only
# difference is which toggles it flips: graphical/gaming OFF, server ON. This is
# the payoff of the options pattern — one module set, very different machines.
{
  imports = [
    ../../modules/nixos
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  fleet = {
    user = {
      name = "nknox";
      fullName = "Nathan Knox";
      email = "nathan.knox@gmail.com";
    };

    # Headless server: no desktop, no gaming, server services ON.
    graphical.enable = false;
    gaming.enable = false;
    server.enable = true;

    # Theme options are irrelevant headless, but harmless to leave at defaults.
  };
}
