{ inputs
, stdenv
}:

inputs.nxc.lib.compose {
  nixpkgs = inputs.unstable;

  inherit (stdenv.hostPlatform) system;

  extraConfigurations = [
    inputs.self.nixosModules.base
    ({ lib, ... }: { boot.initrd.systemd.enable = lib.mkForce false; })
  ];

  # stub
  composition.nodes.nxc = { };
}
