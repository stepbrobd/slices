{ inputs
, stdenv
}:

(inputs.nixpkgs.lib.nixosSystem {
  inherit (stdenv.hostPlatform) system;

  specialArgs = { inherit inputs; };

  modules = [
    inputs.g5k.nixosModules.g5k-image-systemd
    inputs.self.nixosModules.base
  ];
}).config.system.build.g5k-image
