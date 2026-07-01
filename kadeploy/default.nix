{ inputs
, stdenv
}:

let
  closure = inputs.unstable.lib.nixosSystem {
    inherit (stdenv.hostPlatform) system;

    modules = [
      inputs.g5k.nixosModules.g5k-image-systemd
      inputs.self.nixosModules.base
    ];
  };
in
closure.config.system.build.g5k-image.overrideAttrs { passthru = { inherit closure; }; }
