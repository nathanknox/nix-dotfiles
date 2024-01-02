{
  description = "Home Manager configuration for Nathan Knox ";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
      };

    in {
      homeConfigurations.desktop = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { };
        pkgs = pkgsForSystem "x86_64-linux";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./desktop.nix ./common.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to common.nix
      };
      homeConfigurations.laptop = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "nathan.knox";
          homeDirectory = "/Users/nathan.knox";
        };
        pkgs = pkgsForSystem "x86-64-darwin";
        modules = [ ./laptop.nix ./common.nix ];
      };
    };
}
