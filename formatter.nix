{ lib
, writeShellScriptBin
, deno
, nixpkgs-fmt
, typstyle
}:

writeShellScriptBin "formatter" ''
  set -eoux pipefail
  shopt -s globstar
  # ${lib.getExe deno} fmt readme.md
  ${lib.getExe nixpkgs-fmt} .
  ${lib.getExe typstyle} --inplace **/*.typ
''
