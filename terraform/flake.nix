{
  description = "Nathan's Terraform Dev Env";

  # Flake inputs
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2305.491812.tar.gz";
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      # Overlays enable you to customize the Nixpkgs attribute set
      overlays = [
        # (final: prev:
        #   let jdk = prev.openjdk17; in
        #   # sets jre/jdk overrides that use the openjdk17 package
        #   {
        #     jre = jdk;
        #     inherit jdk;
        #   })
      ];

      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit overlays system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            terraform
            terraformer
            terraform-ls
            azure-cli
          ];
        };
      });
    };
}
