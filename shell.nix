{ mkShell
, nixpkgs-fmt
}:

mkShell {
  inputsFrom = [ ];

  packages = [
    nixpkgs-fmt
  ];
}
