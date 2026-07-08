{
  outputs = inputs: inputs.parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    flake.overlays.default = final: _: {
      inherit inputs;
      kadeploy = final.callPackage ./kadeploy { };
      nxc = final.callPackage ./nxc { };
      slides = final.callPackage ./slides { };
    };

    flake.nixosModules.base = ./modules/base.nix;

    perSystem = { pkgs, system, inputs', ... }: {
      _module.args.pkgs = import inputs.unstable { inherit system; overlays = [ inputs.self.overlays.default ]; };
      devShells.default = pkgs.callPackage ./shell.nix { };
      formatter = pkgs.callPackage ./formatter.nix { };
      legacyPackages = {
        inherit (pkgs) kadeploy nxc slides;
        inherit (inputs'.nxc.packages) nixos-compose;
      };
    };
  };

  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.stable.url = "github:nixos/nixpkgs/25.05";
  inputs.systems.url = "github:nix-systems/triplet";

  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "unstable";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.utils.inputs.systems.follows = "systems";

  inputs.g5k.url = "github:oar-team/nixos-g5k-image";
  inputs.g5k.inputs.nixpkgs.follows = "unstable";
  inputs.g5k.inputs.kapack.follows = "";

  inputs.nxc.url = "gitlab:nixos-compose/nixos-compose/g5k-fix?host=gitlab.inria.fr";
  inputs.nxc.inputs.nixpkgs.follows = "stable";
  inputs.nxc.inputs.unstable.follows = "unstable";
  inputs.nxc.inputs.flake-utils.follows = "utils";
  inputs.nxc.inputs.kapack.follows = "kapack";
  inputs.kapack.url = "github:oar-team/nur-kapack/25.05";
  inputs.kapack.inputs.nixpkgs.follows = "stable";
  inputs.kapack.inputs.flake-utils.follows = "utils";

  nixConfig.extra-substituters = [ "https://cache.ysun.co" ];
  nixConfig.extra-trusted-public-keys = [ "cache.ysun.co-1:WxPYwT5g3kt9XhUhHPpNLZKI9HIOsVVAuqSHpok8Qt4=" ];
}
