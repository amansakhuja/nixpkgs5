{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, canfigger
, ncurses
}:

stdenv.mkDerivation rec {
  pname = "rmw";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "theimpossibleastronaut";
    repo = "rmw";
    rev = "v${version}";
    hash = "sha256-BN4Stdn1KAfLHC7F/lO4i5ZuBb6Zm6Z1wOzrbNcH8+c=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    canfigger
    ncurses
  ];

  meta = with lib; {
    description = "Trashcan/ recycle bin utility for the command line";
    homepage = "https://github.com/theimpossibleastronaut/rmw";
    changelog = "https://github.com/theimpossibleastronaut/rmw/blob/${src.rev}/ChangeLog";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dit7ya ];
    mainProgram = "rmw";
  };
}
