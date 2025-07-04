{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "c99sh";
  version = "1.1.0-unstable-2024-02-12";

  src = fetchFromGitHub {
    owner = "RhysU";
    repo = "c99sh";
    rev = "f01d549c38878561d27bd1112ed49ccf7211a85c";
    hash = "sha256-9iQLGJBud4KsUb1slH6sQRqeVfEC6ZfJ6cwuZ5e9a+c=";
  };

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/bin/
    cp --no-dereference c*sh $out/bin # c11sh and cxxsh

    runHook postInstall
  '';

  meta = {
    description = ''
      A shebang-friendly script for "interpreting" single C99, C11,
      and C++ files, including rcfile support.
    '';
    homepage = "https://github.com/RhysU/c99sh";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "c99sh";
  };
}
