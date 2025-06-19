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
    description = "Feature-rich pinyin schema for Rime, standard edition";
    longDescription = ''
      万象拼音标准版 is a full and double pinyin input schema for Rime based on
      [万象 dictionaries and grammar models](https://github.com/amzxyz/RIME-LMDG),
      supporting multiple input styles, tonal dictionaries and predictions.

      The upstream `default.yaml` is included as
      `wanxiang_suggested_default.yaml`.
      To enable it, please modify your `default.custom.yaml` as such:

      ```yaml
      patch:
        __include: wanxiang_suggested_default:/
      ```

      For further fine-grained tweaks, refer to it's
      [README page](https://github.com/amzxyz/rime_wanxiang).

      Please note that, the schema requires the grammar model
      `wanxiang-lts-zh-hans.gram` to work. However, it is
      [released](https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS) by
      carelessly overriding the old version of the file under the same tag
      (see the [discussion](https://github.com/amzxyz/RIME-LMDG/issues/22)).
      This is against the reproducibility philosophy of Nix so we can't include
      it within this package. Same goes for dictionary releases.

      To make it easier updating grammar model and dictionaries, users can
      run the helper script `update-rime-wanxiang-dict` shipped with this
      package.
    '';
    homepage = "https://github.com/amzxyz/rime_wanxiang";
    downloadPage = "https://github.com/amzxyz/rime_wanxiang/releases";
    changelog = "https://github.com/amzxyz/rime_wanxiang/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc-by-40;
    maintainers = with lib.maintainers; [ rc-zb ];
    platforms = lib.platforms.all;
  };
})
