{
  callPackage,
  lib,
  haskell,
  haskellPackages,
}:

let
  backend-pkg = (haskellPackages.callPackage ./generated-backend-package.nix { }).overrideScope (
    final: prev: {
      ansi-wl-pprint = final.ansi-wl-pprint_0_6_9;
    }
  );

  frontend-pkg = callPackage ./generated-frontend-package.nix { };
in
frontend-pkg."gren-lang-0.5.4"
