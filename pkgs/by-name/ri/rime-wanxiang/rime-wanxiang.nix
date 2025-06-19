{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  librime,
  rime-data,
  nix-update-script,
  callPackage,
}:

let
  updater = callPackage ./dict-updater.nix {};

in stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-wanxiang";
  version = "7.1.1";

  src = fetchFromGitHub {
    owner = "amzxyz";
    repo = "rime_wanxiang";
    tag = "v" + finalAttrs.version;
    hash = "sha256-SPKUTWwyxN/pLn9cSFZL3+RfPYfQuNoOehYRMTOoC4I=";
  };

  nativeBuildInputs = [
    librime
    rime-data
  ];

  buildInputs = [
    updater
  ];

  dontConfigure = true;

  patchPhase = ''
    runHook prePatch

    rm -r .github custom LICENSE squirrel.yaml weasel.yaml *.md *.trime.yaml

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    for s in *.schema.yaml; do
        rime_deployer --compile "$s" . ${rime-data}/share/rime-data ./build
    done

    rm build/*.txt

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    data_dir=$out/share/rime-data
    bin_dir=$out/bin
    mkdir -p $data_dir $bin_dir

    mv default.yaml wanxiang_suggested_default.yaml

    cp -pr -t $data_dir *
    ln -s ${updater}/bin/* $bin_dir

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Feature-rich pinyin schema for Rime, basic edition";
    longDescription = ''
      万象拼音基础版 is a basic quanpin and shuangpin input schema for Rime based on
      [万象 dictionaries and grammar models](https://github.com/amzxyz/RIME-LMDG),
      supporting traditional shuangpin as well as tonal schemata such as 自然龙 and
      龙码.

      The schema requires to work the grammar model `wanxiang-lts-zh-hans.gram`.
      However, this file is
      [released](https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS) by
      carelessly overriding the old versions
      (see the [discussion](https://github.com/amzxyz/RIME-LMDG/issues/22)). So
      we can't pack it into Nixpkgs, which demands reproducibility. You have to
      download it yourself and place it in the user directory of Rime.

      The upstream `default.yaml` is included as
      `wanxiang_suggested_default.yaml`. To enable it, please modify your
      `default.custom.yaml` as such:

      ```yaml
      patch:
        __include: wanxiang_suggested_default:/
      ```
    '';
    homepage = "https://github.com/amzxyz/rime_wanxiang";
    downloadPage = "https://github.com/amzxyz/rime_wanxiang/releases";
    changelog = "https://github.com/amzxyz/rime_wanxiang/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc-by-40;
    maintainers = with lib.maintainers; [ rc-zb ];
    platforms = lib.platforms.all;
  };
})
