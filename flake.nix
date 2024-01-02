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
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsForSystem = system: import nixpkgs {
        inherit system;
      };

    in {
      homeConfigurations."nknox" = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        username = "nknox";
        homeDirectory = "/home/nknox";
        pkgs = pkgsForSystem system;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      homeConfigurations.laptop = home-manager.lib.homeManagerConfiguration {
        system = "x86-64-darwin";
        username = "nathan.knox";
        homeDirectory = "/Users/nathan.knox";
        pkgs = pkgsForSystem system;
        modules = [ ./home.nix ];
      };
}
