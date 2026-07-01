{ inputs
, stdenv
}:

(inputs.nixpkgs.lib.nixosSystem {
  inherit (stdenv.hostPlatform) system;

  specialArgs = { inherit inputs; };

  modules = [
    ./base.nix
    inputs.g5k.nixosModules.g5k-image-systemd
  ];
}).config.system.build.g5k-image
