{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
  libX11,
  xorg,
}:

buildDotnetModule rec {
  pname = "terraria-map-editor";
  version = "5.0.0-beta15";

  src = fetchFromGitHub {
    owner = "TEdit";
    repo = "Terraria-Map-Editor";
    tag = version;
    hash = "sha256-ysUKNzyFNvX6hAySeK8MgzJUYy6wvae29XTMxzSg8MQ=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  projectFile = [ "src/TEdit.sln" ];
  nugetDeps = ./deps.json;
  selfContainedBuild = true;


  buildInputs = [
    dotnetCorePackages.sdk_9_0
    dotnetCorePackages.runtime_9_0
  ];

  runtimeDeps = [
    libX11
    xorg.libICE
    xorg.libSM
  ];

  buildPhase = ''
    runHook preBuild

    dotnet publish \
      src/TEdit5/TEdit5.csproj \
      --configuration Release \
      --runtime linux-x64 \
      --self-contained true \
      -o publish

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r publish/* $out/bin/
    cp ${libX11}/lib/libX11.so.6 $out/bin/
    cp ${xorg.libICE}/lib/libICE.so.6 $out/bin/
    cp ${xorg.libSM}/lib/libSM.so.6 $out/bin/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stand alone, open source map editor for Terraria";
    changelog = "https://github.com/TEdit/Terraria-Map-Editor/releases/tag/${src.tag}";
    homepage = "https://github.com/TEdit/Terraria-Map-Editor";
    license = lib.licenses.mspl;
    mainProgram = "TEdit5";
    maintainers = with lib.maintainers; [ osbm ];
  };
}
