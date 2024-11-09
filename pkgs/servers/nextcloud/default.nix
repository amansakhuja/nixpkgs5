{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  nixosTests,
  nextcloud28Packages,
  nextcloud29Packages,
  nextcloud30Packages,
  nodejs,
}:

let
  generic =
    {
      version,
      hash,
      npmHash,
      eol ? false,
      extraVulnerabilities ? [ ],
      packages,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "nextcloud";
      inherit version;

      src = fetchFromGitHub {
        owner = "nextcloud";
        repo = "server";
        rev = "refs/tags/v${version}";
        inherit hash;
        fetchSubmodules = true;
      };

      nativeBuildInputs = [ nodejs ];

      npmDeps = fetchNpmDeps {
        inherit (finalAttrs) src;
        name = "${finalAttrs.pname}-npm-deps";
        hash = npmHash;
      };

      passthru = {
        tests = lib.filterAttrs (
          key: _: (lib.hasSuffix (lib.versions.major version) key)
        ) nixosTests.nextcloud;
        inherit packages;
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/
        cp -R . $out/
        runHook postInstall
      '';

      meta = {
        changelog = "https://nextcloud.com/changelog/#${lib.replaceStrings [ "." ] [ "-" ] version}";
        description = "Sharing solution for files, calendars, contacts and more";
        homepage = "https://nextcloud.com";
        maintainers = with lib.maintainers; [
          schneefux
          bachp
          globin
          ma27
        ];
        license = lib.licenses.agpl3Plus;
        platforms = lib.platforms.linux;
        knownVulnerabilities =
          extraVulnerabilities ++ (lib.optional eol "Nextcloud version ${version} is EOL");
      };
    });
in
{
  nextcloud28 = generic {
    version = "28.0.11";
    hash = "sha256-Af+QBkWGpQfel2se3DFXNYzX9X3T4lix2Cm9kWizzIM=";
    npmHash = "sha256-1mTc3yIItE4aPStGA6ILnt3YqRYagzc6wHsX/76qpkE=";
    packages = nextcloud28Packages;
  };

  nextcloud29 = generic {
    version = "29.0.8";
    hash = "sha256-I+HdAfLo3NHv4FA6dqr5vecjyiFsccRN2IYC1KHxBDo=";
    npmHash = "sha256-XD3pj+Ygf8WdNHQM8q84jbKa41LYDOtxK5DaAxIUMiY=";
    packages = nextcloud29Packages;
  };

  nextcloud30 = generic {
    version = "30.0.1";
    hash = "sha256-cE5YLeDhw1pL++zwX2H+/H6WvwXV+yvaQOS/MQP0GPM=";
    npmHash = "sha256-DvWidXB7FF+4pbkZnEiP+Dk49wvS2fZEZSh8O5nmoNM=";
    packages = nextcloud30Packages;
  };
}
