{
  lib,
  buildDunePackage,
  fetchurl,
  domain-local-await,
  domain-local-timeout,
  alcotest,
  multicore-magic,
  backoff,
  domain_shims,
  mdx,
}:

buildDunePackage rec {
  pname = "kcas";
  version = "0.7.0";

  minimalOCamlVersion = "4.13.0";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/kcas/releases/download/${version}/kcas-${version}.tbz";
    hash = "sha256-mo/otnkB79QdyVgLw1sZFfkR/Z/l15cRVfEYPPd6H5E=";
  };

  propagatedBuildInputs = [
    domain-local-await
    domain-local-timeout
    multicore-magic
    backoff
    domain_shims
    mdx
  ];

  nativeBuildInputs = [ mdx ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    homepage = "https://github.com/ocaml-multicore/kcas";
    description = "STM based on lock-free MCAS";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
