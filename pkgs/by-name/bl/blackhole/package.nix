{
  stdenv,
  lib,
  fetchFromGitHub,
  xcbuildHook,
  apple-sdk,
  audioChannel ? "256ch",
}:
let
  bundleId = "audio.existential.BlackHole${audioChannel}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "blackhole";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "existentialaudio";
    repo = "BlackHole";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jFKi5LJdTOMFa1mErH6WsjgCtLCKzwpgn2+T3Fp9MtQ=";
  };

  nativeBuildInputs = [
    xcbuildHook
    apple-sdk
  ];

  xcbuildFlags = [
    "-project"
    "BlackHole.xcodeproj"
    "-configuration"
    "Release"
    "PRODUCT_BUNDLE_IDENTIFIER=${bundleId}"
    "GCC_PREPROCESSOR_DEFINITIONS=$GCC_PREPROCESSOR_DEFINITIONS kDriver_Name=\\\"${finalAttrs.pname}${audioChannel}\\\" kPlugIn_BundleID=\\\"${bundleId}\\\" kPlugIn_Icon=\\\"BlackHole.icns\\\""
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Library/Audio/Plug-Ins/HAL
    ls -la .


    mv Products/Release/BlackHole.driver $out/Library/Audio/Plug-Ins/HAL/Blackhole${audioChannel}.driver

    # Create a marker file so the derivation produces output
    touch $out/.build-completed

    runHook postInstall
  '';

  meta = {
    description = "Virtual audio driver for macOS";
    homepage = "https://existential.audio/blackhole";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ eveeifyeve ];
  };
})
