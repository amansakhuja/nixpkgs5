{
  autoreconfHook,
  fetchFromGitHub,
  lib,
  libpq,
  nix-update-script,
  openssl,
  stdenv,

  withLibiodbc ? false,
  libiodbc,

  withUnixODBC ? true,
  unixODBC,
}:

assert lib.xor withLibiodbc withUnixODBC;

stdenv.mkDerivation rec {
  pname = "psqlodbc";
  version = "${builtins.replaceStrings [ "_" ] [ "." ] (lib.strings.removePrefix "REL-" src.tag)}";

  src = fetchFromGitHub {
    owner = "postgresql-interfaces";
    repo = "psqlodbc";
    tag = "REL-17_00_0002";
    hash = "sha256-zCjoX+Ew8sS5TWkFSgoqUN5ukEF38kq+MdfgCQQGv9w=";
  };

  buildInputs =
    [
      libpq
      openssl
    ]
    ++ lib.optional withLibiodbc libiodbc
    ++ lib.optional withUnixODBC unixODBC;

  nativeBuildInputs = [
    autoreconfHook
  ];

  strictDeps = true;

  configureFlags =
    [
      "CPPFLAGS=-DSQLCOLATTRIBUTE_SQLLEN" # needed for cross
      "--with-libpq=${lib.getDev libpq}"
    ]
    ++ lib.optional withLibiodbc "--with-iodbc=${libiodbc}"
    ++ lib.optional withUnixODBC "--with-unixodbc=${unixODBC}";

  passthru =
    {
      updateScript = nix-update-script { };
    }
    // lib.optionalAttrs withUnixODBC {
      fancyName = "PostgreSQL";
      driver = "lib/psqlodbcw.so";
    };

  meta = {
    homepage = "https://odbc.postgresql.org/";
    description = "ODBC driver for PostgreSQL";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    teams = libpq.meta.teams;
  };
}
