{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  git,
  fontconfig,
  libX11,
  libXi,
  freetype,
  mesa,
}:

let
  bext = fetchFromGitHub {
    owner = "BRL-CAD";
    repo = "bext";
    rev = "";
    hash = "";
  };

  version = "7.40.2";
  tag = "rel-${lib.replaceStrings [ "." ] [ "-" ] version}";
in

stdenv.mkDerivation rec {
  pname = "brlcad";
  inherit version;

  src = fetchFromGitHub {
    owner = "BRL-CAD";
    repo = "brlcad";
    inherit tag;
    hash = "sha256-v2MxatzplBpZ4Y/PAlAxAe3uKu8HboBu1+WM0R4yTwo=";
  };

  # patches = [
  #   # This commit was bringing an impurity in the rpath resulting in:
  #   # RPATH of binary /nix/store/rq2hjvfgq2nvh5zxch51ij34rqqdpark-brlcad-7.38.0/bin/tclsh contains a forbidden reference to /build/
  #   (fetchpatch {
  #     url = "https://github.com/BRL-CAD/brlcad/commit/fbdbf042b2db4c7d46839a17bbf4985cdb81f0ae.patch";
  #     revert = true;
  #     hash = "sha256-Wfihd7TLkE8aOpLdDtYmhhd7nZijiVGh1nbUjWr/BjQ=";
  #   })
  # ];

  nativeBuildInputs = [
    cmake
    git
  ];

  buildInputs = [
    fontconfig
    libX11
    libXi
    freetype
    mesa
  ];

  cmakeFlags = [ "-DBRLCAD_ENABLE_STRICT=OFF" ];

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=array-bounds"
  ];

  meta = {
    homepage = "https://brlcad.org";
    description = "BRL-CAD is a powerful cross-platform open source combinatorial solid modeling system";
    changelog = "https://github.com/BRL-CAD/brlcad/releases/tag/${tag}";
    license = with lib.licenses; [
      lgpl21
      bsd2
    ];
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
    badPlatforms = [
      # error Exactly one of ON_LITTLE_ENDIAN or ON_BIG_ENDIAN should be defined.
      "aarch64-linux"
    ];
  };
}
