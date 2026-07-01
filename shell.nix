{ mkShell
, slides
, deno
, nixpkgs-fmt
}:

mkShell {
  inputsFrom = [ slides ];

  packages = [
    deno
    nixpkgs-fmt
  ];
}
