{
  outputs = inputs: inputs.parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    flake.overlays.default = final: _: { slides = final.callPackage ./slides { }; };

    perSystem = { pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs { inherit system; overlays = [ inputs.self.overlays.default ]; };
      devShells.default = pkgs.callPackage ./shell.nix { };
      formatter = pkgs.callPackage ./formatter.nix { };
      packages = { inherit (pkgs) slides; };
    };
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.systems.url = "github:nix-systems/default";
}
