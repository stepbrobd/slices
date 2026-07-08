{ lib
, writeShellScriptBin
, deno
, nixpkgs-fmt
, typstyle
}:

writeShellScriptBin "formatter" ''
  set -eoux pipefail
  shopt -s globstar

  root="$PWD"
  while [[ ! -f "$root/.git/index" ]]; do
    if [[ "$root" == "/" ]]; then
      exit 1
    fi
    root="$(dirname "$root")"
  done
  pushd "$root" > /dev/null

  ${lib.getExe deno} fmt readme.md
  ${lib.getExe nixpkgs-fmt} .
  ${lib.getExe typstyle} --inplace **/*.typ

  popd
''
