{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  libgcc,
  openssl,
}:

let
  version = "5.9.1";
  # Hash corresponds to 5.9.1
  base = "https://binaries.prisma.sh/all_commits/23fdc5965b1e05fc54e5f26ed3de66776b93de64/debian-openssl-3.0.x/";

  hashes = {
    schema-engine = "sha256-Hv1AHZEijrV36mihK4+AEY6p6uGj/61Wh8e7i3qwOBw=";
    query-engine = "sha256-hE9CCGIAldgyLVRtyWqk3hxpe8E+IOCGPbIyNZ0RHfw=";
    "libquery_engine.so.node" = "sha256-Z4o6RDNP32m7Xbnw0HItKuMAv4ZVHGOulwGwZMC31bY=";
  };

  files = lib.mapAttrs (
    name: hash:
    fetchurl {
      url = "${base}${name}.gz";
      inherit hash;
    }
  ) hashes;

  unzipCommands = lib.mapAttrsToList (name: file: "gunzip -c ${file} > ${name}") files;
in
stdenv.mkDerivation {
  pname = "prisma-engines";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    libgcc
    openssl
  ];

  buildPhase = ''
    mkdir -p $out/{bin,lib}
    ${lib.concatLines unzipCommands}

    mv *.so.node $out/lib
    mv * $out/bin

    chmod +x $out/bin/*
  '';
}
