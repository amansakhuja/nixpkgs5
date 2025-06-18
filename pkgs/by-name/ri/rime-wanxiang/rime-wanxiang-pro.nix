{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  librime,
  rime-data,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-wanxiang-pro";
  version = "7.1";

  src = fetchFromGitHub {
    owner = "amzxyz";
    repo = "rime_wanxiang_pro";
    tag = "v" + finalAttrs.version;
    hash = "sha256-CpTMSK/ra2gluWuYKk33+YiNmJBsp3IBeA6VJgCEXMA=";
  };

  nativeBuildInputs = [
    librime
    rime-data
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

    dst=$out/share/rime-data
    mkdir -p $dst

    mv default.yaml wanxiang_pro_suggested_default.yaml

    cp -pr -t $dst *

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Feature-rich pinyin schema for Rime, enhanced edition for double pinyin";
    longDescription = ''
      万象拼音双拼辅助码增强版 is a enhanced double pinyin input schema for Rime based
      on [万象 dictionaries and grammar models](https://github.com/amzxyz/RIME-LMDG),
      supporting traditional shuangpin as well as tonal schemata such as 自然龙 and 龙码.

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
        __include: wanxiang_pro_suggested_default:/
      ```

      For further fine-grained tweaks, refer to it's [README page](https://github.com/amzxyz/rime_wanxiang_pro)
      and [customization guide](https://github.com/amzxyz/rime_wanxiang_pro/tree/main/custom).
    '';
    homepage = "https://github.com/amzxyz/rime_wanxiang_pro";
    downloadPage = "https://github.com/amzxyz/rime_wanxiang_pro/releases";
    changelog = "https://github.com/amzxyz/rime_wanxiang_pro/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc-by-40;
    maintainers = with lib.maintainers; [ peromage ];
    platforms = lib.platforms.all;
  };
})
