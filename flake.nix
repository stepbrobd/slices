{
  outputs = inputs: inputs.parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    flake.overlays.default = final: _: {
      inherit inputs;
      kadeploy = final.callPackage ./kadeploy { };
      slides = final.callPackage ./slides { };
    };

    flake.nixosModules.base = ./modules/base.nix;

    perSystem = { pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs { inherit system; overlays = [ inputs.self.overlays.default ]; };
      devShells.default = pkgs.callPackage ./shell.nix { };
      formatter = pkgs.callPackage ./formatter.nix { };
      packages = { inherit (pkgs) kadeploy slides; };
    };
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.systems.url = "github:nix-systems/triplet";
  inputs.g5k.url = "github:oar-team/nixos-g5k-image";
  inputs.g5k.inputs.nixpkgs.follows = "nixpkgs";
  inputs.g5k.inputs.kapack.follows = "";

  nixConfig.extra-substituters = [ "https://cache.ysun.co" ];
  nixConfig.extra-trusted-public-keys = [ "cache.ysun.co-1:WxPYwT5g3kt9XhUhHPpNLZKI9HIOsVVAuqSHpok8Qt4=" ];
}
