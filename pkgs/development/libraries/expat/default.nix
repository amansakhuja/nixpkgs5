{ stdenv, fetchurl, fetchpatch }:

stdenv.mkDerivation rec {
  name = "expat-2.2.6";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    sha256 = "1wl1x93b5w457ddsdgj0lh7yjq4q6l7wfbgwhagkc8fm2qkkrd0p";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2018-20843.patch";
      url = "https://github.com/libexpat/libexpat/commit/11f8838bf99ea0a6f0b76f9760c43704d00c4ff6.patch";
      sha256 = "1i7bq9sp2k5348dvbfv26bprzv6ka1abf0j5ixjaff9alndm4f19";
      stripLen = 1;
    })
    (fetchpatch {
      name = "CVE-2019-15903.patch";
      url = "https://sources.debian.org/data/main/e/expat/2.2.7-2/debian/patches/CVE-2019-15903_Deny_internal_entities_closing_the_doctype.patch";
      sha256 = "0lv4392ihpk71fgaf1fz03gandqkaqisal8xrzvcqnvnq4mnmwxp";
      stripLen = 1;
      excludes = [ "tests/runtests.c" "Changes" ];
    })
  ];

  outputs = [ "out" "dev" ]; # TODO: fix referrers
  outputBin = "dev";

  configureFlags = stdenv.lib.optional stdenv.isFreeBSD "--with-pic";

  outputMan = "dev"; # tiny page for a dev tool

  doCheck = true; # not cross;

  preCheck = ''
    patchShebangs ./run.sh
    patchShebangs ./test-driver-wrapper.sh
  '';

  meta = with stdenv.lib; {
    homepage = http://www.libexpat.org/;
    description = "A stream-oriented XML parser library written in C";
    platforms = platforms.all;
    license = licenses.mit; # expat version
  };
}
