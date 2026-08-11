{
  description = "Home Manager configuration for Nathan Knox ";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    #
    # Tracking the `nixpkgs-unstable` channel branch rather than a `nixos-XX.YY`
    # release. The channel branch only advances after Hydra has built it, so
    # packages still come prebuilt from cache.nixos.org.
    #
    # home-manager must track `master` to match: the `release-XX.YY` branches are
    # pinned to their matching nixpkgs release, and pairing release home-manager
    # with unstable nixpkgs is an unsupported combination.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      pkgsForSystem =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

    in
    {
      homeConfigurations.desktop = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { };
        pkgs = pkgsForSystem "x86_64-linux";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./desktop.nix
          ./common.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to common.nix
      };
      homeConfigurations.laptop = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "nathan.knox";
          homeDirectory = "/Users/nathan.knox";
        };
        pkgs = pkgsForSystem "aarch64-darwin";
        modules = [
          ./laptop.nix
          ./common.nix
        ];
      };
    };
}
