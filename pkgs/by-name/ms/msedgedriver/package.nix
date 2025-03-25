{
  autoPatchelfHook,
  fetchzip,
  glib,
  lib,
  libxcb,
  nspr,
  nss,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "msedgedriver";
  # finding a version that has all 4 builds is a pain
  # https://msedgewebdriverstorage.z22.web.core.windows.net/?form=MA13LH
  version = "136.0.3240.92";

  src =
    let
      inherit (stdenvNoCC.hostPlatform) system;
      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
      suffix = selectSystem {
        x86_64-linux = "linux64";
        aarch64-linux = "arm64";
        x86_64-darwin = "mac64";
        aarch64-darwin = "mac64_m1";
      };

      hash = selectSystem {
        x86_64-linux = "sha256-LKpTAfxvL1qhAQ5PMtl5TryodlOc0Gl14oAangqUR34=";
        aarch64-linux = "sha256-NmZTABjJpR8j4UlAW1bz/Gtj22bcTSHBin5+TMt2nN4=";
        x86_64-darwin = "sha256-kQMFe96DobQD5LlB1vSkjtAIZsX1c6D7XRAm1gHZQmw=";
        aarch64-darwin = "sha256-qxd7/nqnqCJ15YAOUH/xZCM22qNETnmgBJkisn10iDk=";
      };
    in
    fetchzip {
      url = "https://msedgedriver.azureedge.net/${finalAttrs.version}/edgedriver_${suffix}.zip";
      inherit hash;
      stripRoot = false;
    };

  buildInputs = [
    glib
    libxcb
    nspr
    nss
  ];

  nativeBuildInputs = lib.optionals (!stdenvNoCC.hostPlatform.isDarwin) [ autoPatchelfHook ];

  installPhase =
    if stdenvNoCC.hostPlatform.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/{Applications/msedgedriver,bin}
        cp -R . $out/Applications/msedgedriver

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        install -m777 -D "msedgedriver" $out/bin/msedgedriver

        runHook postInstall
      '';

  meta = {
    homepage = "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver";
    description = "WebDriver implementation that controls an Edge browser running on the local machine";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ cholli ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "msedgedriver";
  };
})
