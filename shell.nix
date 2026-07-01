{ inputs
, lib
, stdenv
, mkShell
, slides
, deno
, nixpkgs-fmt
}:

mkShell {
  inputsFrom = [ slides ];

  packages = [
    deno
    nixpkgs-fmt
  ] ++ lib.optionals stdenv.isLinux [
    inputs.nxc.packages.${stdenv.hostPlatform.system}.nixos-compose
  ];
}
