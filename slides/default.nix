{ stdenvNoCC
, typst
}:

stdenvNoCC.mkDerivation {
  pname = "slides";
  version = "2026.701.0";

  src = ./.;

  nativeBuildInputs = [ (typst.withPackages (_: with _; [ polylux ])) ];

  buildPhase = ''
    runHook preBuild
    typst compile main.typ main.pdf
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out;
    mv main.pdf $out/
    runHook postInstall
  '';
}
