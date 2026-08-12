{
  # ===========================================================================
  # rocinante — an opinionated, barebones, teaching-grade NixOS + Hyprland flake
  # ===========================================================================
  #
  # This flake defines TWO machines (NixOS calls them "nixosConfigurations"):
  #
  #   * rocinante — the all-in-one desktop: development + gaming, Hyprland,
  #                 AMD RX 9070 XT (RDNA4). This is the folder name AND the
  #                 hostname; it gets the bulk of the graphical/gaming content.
  #   * tycho     — a headless media/dev server (MINISFORUM MS-01, Intel i9 +
  #                 Iris Xe iGPU). No desktop; reuses the SAME shared modules
  #                 with the graphical/gaming toggles turned off.
  #
  # Teaching notes are inline throughout. Where there is a real design fork
  # (e.g. "wire home-manager as a NixOS module" vs "standalone home-manager")
  # both routes are shown: the ACTIVE one is uncommented, the ALTERNATIVE is
  # left commented directly beneath it so you can flip between them and learn
  # the difference by doing.
  #
  # Inspirations, and what each contributes:
  #   * vimjoyer          -> the hosts/ + modules/{nixos,home-manager}/ layout,
  #                          per-app modules, and custom `options`/`config`
  #                          modules (see modules/options.nix, modules/nixos/users.nix).
  #   * tonybanters (tonybtw) -> home-manager wired INTO the system (one
  #                          `nixos-rebuild`), and Hyprland kept as plaintext
  #                          dotfiles symlinked with mkOutOfStoreSymlink so you
  #                          can hot-edit + `hyprctl reload` without a rebuild.
  #   * omarchy / omarchy-nix -> a curated static theme registry (themes/) and
  #                          an opinionated `options.rocinante.*` schema.
  #   * saneaspect        -> the Material-You (matugen) "wallpaper drives the
  #                          palette" route + the rounded "island" Waybar look,
  #                          kept in SEPARATE files and enabled by uncommenting
  #                          a single import (see modules/home-manager/theme-matugen.nix).

  description = "rocinante: opinionated NixOS + Hyprland (rocinante desktop, tycho server)";

  inputs = {
    # -------------------------------------------------------------------------
    # nixpkgs channel choice — WHY unstable:
    #
    # rocinante's GPU is an AMD RX 9070 XT (RDNA4), which is very new hardware.
    # RDNA4 needs a recent kernel + recent Mesa to work well. The stable NixOS
    # release (e.g. nixos-25.05) can lag on brand-new GPUs, so we track
    # nixos-unstable to stay close to upstream kernel/Mesa.
    #
    # `nixos-unstable` (not `nixpkgs-unstable`) is the channel that Hydra has
    # already built AND passed the NixOS test suite on, so you still get cache
    # hits from cache.nixos.org while being current enough for RDNA4.
    #
    # If you ever want maximum stability instead (e.g. for tycho alone), you can
    # pin a release channel and use it per-host — see the commented `nixpkgs-stable`
    # input below and how a host could `follows` it.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # OPTIONAL stable channel, kept commented. A common pattern is to run the
    # desktop on unstable (fresh GPU support) and a server on stable. If you
    # adopt it, add `nixpkgs-stable` to the outputs function args and build
    # tycho from `nixpkgs-stable.lib.nixosSystem` instead.
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # home-manager must track `master` to match nixpkgs `nixos-unstable`. The
    # `release-XX.YY` branches are pinned to their matching nixpkgs release;
    # pairing a release home-manager with unstable nixpkgs is unsupported.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ROUTE B (saneaspect Material-You): matugen generates a Material You color
    # scheme from your wallpaper. It is only needed if you enable the matugen
    # theme route. Kept as an input so the route is one uncomment away, but it
    # does not affect the build until referenced.
    #
    # matugen.url = "github:InioX/matugen";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Every host here is x86_64-linux. If you later add an aarch64 box (e.g. a
      # Raspberry Pi from your Home Lab notes), factor this into a list and map
      # over it. Kept simple/barebones on purpose.
      system = "x86_64-linux";

      # A tiny helper that builds a NixOS system for a given host directory.
      # This keeps `nixosConfigurations` DRY: each host is just `mkHost "name"`.
      #
      # `specialArgs` threads our flake `inputs` down into every module so any
      # module can reference `inputs.home-manager`, `inputs.matugen`, etc. This
      # is the vimjoyer `extraSpecialArgs`/`specialArgs` pattern.
      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostName; };
          modules = [
            # Host-specific entrypoint. It imports the shared modules it wants
            # and sets `rocinante.*` options for this machine.
            ./hosts/${hostName}

            # ROUTE A (ACTIVE): home-manager as a NixOS module.
            # One `sudo nixos-rebuild switch` builds BOTH the system and the
            # user's home. This is the tonybanters approach and the simplest
            # mental model for a single-user machine.
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              # Pass flake inputs into HM modules too (matches specialArgs above).
              home-manager.extraSpecialArgs = { inherit inputs hostName; };
              # The actual per-user home wiring lives in the HM aggregator.
              # `users.<name>` is set inside hosts/<host>/default.nix via the
              # `rocinante.user.name` option so it stays declarative and DRY.
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        rocinante = mkHost "rocinante";
        tycho = mkHost "tycho";
      };

      # -----------------------------------------------------------------------
      # ROUTE B (ALTERNATIVE): standalone home-manager.
      #
      # Instead of (or in addition to) HM-as-a-NixOS-module, you can expose a
      # standalone home configuration and run `home-manager switch --flake .#nknox`.
      # Useful on machines where you don't control the whole OS (e.g. work
      # macbook). Kept commented; uncomment and adapt if you want the two-command
      # workflow. See README "Two ways to wire home-manager".
      #
      # homeConfigurations.nknox = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages.${system};
      #   extraSpecialArgs = { inherit inputs; hostName = "rocinante"; };
      #   modules = [ ./modules/home-manager ];
      # };

      # -----------------------------------------------------------------------
      # Developer experience: a devShell and a formatter, so working ON this
      # repo is pleasant and `nix fmt` / `nix flake check` behave.
      # -----------------------------------------------------------------------

      # `nix fmt` formats every .nix file with the official formatter.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      # `nix develop` drops you into a shell with the Nix tooling used here:
      #   nil       - Nix language server (editor completion/diagnostics)
      #   nixfmt    - formatter (same as `nix fmt`)
      #   statix    - linter for common Nix anti-patterns
      #   deadnix   - finds dead/unused Nix code
      # Pair with direnv (`echo "use flake" > .envrc && direnv allow`) for an
      # auto-loading environment when you cd into this directory.
      devShells.${system}.default =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.mkShell {
          packages = [
            pkgs.nil
            pkgs.nixfmt-rfc-style
            pkgs.statix
            pkgs.deadnix
          ];
          shellHook = ''
            echo "rocinante devshell — nil, nixfmt, statix, deadnix available."
            echo "Try:  nix flake check   |   nix fmt   |   statix check ."
          '';
        };
    };
}
