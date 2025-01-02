{ lib
, fetchFromGitHub
, python3
, yubikey-manager
, gitUpdater
,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gam";
  version = "7.02.05";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "GAM-team";
    repo = "GAM";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-iSBdTDJehitRzrWPbTDS+BGZbY6MkDgBUJyvzPh5QyU=";
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  sourceRoot = "${src.name}/src";

  propagatedBuildInputs = with python3.pkgs; [
    chardet
    cryptography
    distro
    filelock
    google-api-python-client
    google-auth
    google-auth-httplib2
    google-auth-oauthlib
    httplib2
    lxml
    passlib
    pathvalidate
    python-dateutil
    yubikey-manager
  ];

  postPatch = ''
    cp ../README.md readme.md
    substituteInPlace setup.cfg \
      --replace "version = attr: gam.var.GAM_VERSION" "version = ${version}" \
  '';

  pythonImportsCheck = [ "gam" ];

  meta = with lib; {
    description = "Command line management for Google Workspace";
    mainProgram = "gam";
    homepage = "https://github.com/GAM-team/GAM/wiki";
    changelog = "https://github.com/GAM-team/GAM/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ thanegill ];
  };

}
