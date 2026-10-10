{
  description = "Environnement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            typst
            gimp
            gnumake
            img2pdf
            imagemagick
            bun
          ];

          shellHook = ''
            export SOURCE_DATE_EPOCH=$(date +%s)
            echo "Ready !"
          '';
        };
      });
    };
}
