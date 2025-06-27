{
  crystal,
  fetchgit,
  lib,
  ...
}@args:

crystal.buildCrystalPackage rec {
  pname = "exfetch";
  version = "1.3.5";

  src = fetchgit {
    url = "https://codeberg.org/Izder456/exfetch.git";
    rev = "refs/tags/1.3.5";
    hash = "sha256-Dw6NQBcPNpmLWClJ3uPBPPOF5WBMULAn2vEIl4ewkec===";
    fetchSubmodules = true;
  };

  buildPhase = ''
    make bin/exfetch
  '';

  checkPhase = "";

  meta = {
    description = "a shell-extensible fetching utility aiming to be a spiritual successor to crfetch, written in crystal";
    mainProgram = "exfetch";
    homepage = "https://codeberg.org/Izder456/exfetch";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ goose121 ];
  };
}
