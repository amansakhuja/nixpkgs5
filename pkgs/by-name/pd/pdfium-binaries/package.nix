{
  lib,
  stdenv,
  fetchzip,
  python3Packages,
  withV8 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdfium-binaries";
  # also update rev of headers in python3Packages.pypdfium2
  version = "7269";

  src =
    let
      selectSystem =
        attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      system = selectSystem {
        x86_64-linux = "linux-x64";
        aarch64-linux = "linux-arm64";
        x86_64-darwin = "mac-x64";
        aarch64-darwin = "mac-arm64";
      };
    in
    fetchzip {
      url = "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F${finalAttrs.version}/pdfium${lib.optionalString withV8 "-v8"}-${system}.tgz";
      hash =
        if withV8 then
          selectSystem {
            x86_64-linux = "sha256-hj7BV1ZbQeDZYbnqsgNU9HciRMmcGAuchW4OWHCMwGY=";
            aarch64-linux = "sha256-0t4hBtGzZUJhYzB+EZ3V8wDgVoSuMXUKZyBjW17JAt8=";
            x86_64-darwin = "sha256-uY5ptOpJm9bxAL6TQFilFvBEuPCD7yAzFjCeuoOPQiI=";
            aarch64-darwin = "sha256-zpRhm2MfF40sETI+/WhGjFGdHEGmGC7Ql636I3Vl5yI=";
          }
        else
          selectSystem {
            x86_64-linux = "sha256-CPXBV09sDsTjPx4BvZ5YfNINuVE0l72c4vf9vWopJkU=";
            aarch64-linux = "sha256-5Wtf8Zrm7aStyRn+k1ep/Wgvvv+Ort1GZZhIXYpsL+E=";
            x86_64-darwin = "sha256-HpxcdWqminkKfVwAPgjEzTDbzwsWP8kkybLu9cNbt3g=";
            aarch64-darwin = "sha256-ouSzamyLoKi1cve7lUXOUjj+6jA8Q3eS4z7i1fVDRKg=";
          };
      stripRoot = false;
    };

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;
    tests = {
      inherit (python3Packages) pypdfium2;
    };
  };

  meta = {
    description = "Binary distribution of PDFium";
    homepage = "https://github.com/bblanchon/pdfium-binaries";
    license = with lib.licenses; [
      asl20
      mit
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };
})
