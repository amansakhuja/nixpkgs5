{
  lib,
  buildPythonPackage,
  fetchPypi,
  meson,
  meson-python,
  cython_3_1,
  attrs,
  useful-types,
}:
let
  pname = "srctools";
  version = "2.6.0";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QHPRSgu3i443kLeLeJXVpPP0hqMbsi4lScAYHrrfWEM=";
  };

  build-system = [
    meson
    meson-python
    cython_3_1
  ];

  dependencies = [
    attrs
    useful-types
  ];

  pythonImportsCheck = [ "srctools" ];

  meta = {
    description = "Modules for working with Valve's Source Engine file formats";
    homepage = "https://github.com/TeamSpen210/srctools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ different-name ];
  };
}
