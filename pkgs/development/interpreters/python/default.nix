{ pkgs, lib }:

with pkgs;

(let

  # Common passthru for all Python interpreters.
  passthruFun =
    { implementation
    , libPrefix
    , executable
    , sourceVersion
    , pythonVersion
    , packageOverrides
    , sitePackages
    , pythonForBuild
    , self
    }: let
      pythonPackages = callPackage ../../../top-level/python-packages.nix {
        python = self;
        overrides = packageOverrides;
      };
    in rec {
        isPy27 = pythonVersion == "2.7";
        isPy33 = pythonVersion == "3.3"; # TODO: remove
        isPy34 = pythonVersion == "3.4"; # TODO: remove
        isPy35 = pythonVersion == "3.5";
        isPy36 = pythonVersion == "3.6";
        isPy37 = pythonVersion == "3.7";
        isPy2 = lib.strings.substring 0 1 pythonVersion == "2";
        isPy3 = lib.strings.substring 0 1 pythonVersion == "3";
        isPy3k = isPy3;
        isPyPy = interpreter == "pypy";

        buildEnv = callPackage ./wrapper.nix { python = self; inherit (pythonPackages) requiredPythonModules; };
        withPackages = import ./with-packages.nix { inherit buildEnv pythonPackages;};
        pkgs = pythonPackages;
        interpreter = "${self}/bin/${executable}";
        inherit executable implementation libPrefix pythonVersion sitePackages;
        inherit sourceVersion;
        pythonAtLeast = lib.versionAtLeast pythonVersion;
        pythonOlder = lib.versionOlder pythonVersion;
        inherit pythonForBuild;
  };

in {

  python27 = callPackage ./cpython/2.7 {
    self = python27;
    sourceVersion = {
      major = "2";
      minor = "7";
      patch = "17";
      suffix = "";
    };
    sha256 = "0hds28cg226m8j8sr394nm9yc4gxhvlv109w0avsf2mxrlrz0hsd";
    inherit (darwin) CF configd;
    inherit passthruFun;
  };

  python35 = callPackage ./cpython {
    self = python35;
    sourceVersion = {
      major = "3";
      minor = "5";
      patch = "7";
      suffix = "";
    };
    sha256 = "1p67pnp2ca5przx2s45r8m55dcn6f5hsm0l4s1zp7mglkf4r4n18";
    inherit (darwin) CF configd;
    inherit passthruFun;
  };

  python36 = callPackage ./cpython {
    self = python36;
    sourceVersion = {
      major = "3";
      minor = "6";
      patch = "9";
      suffix = "";
    };
    sha256 = "1nkh70azbv866aw5a9bbxsxarsf40233vrzpjq17z3rz9ramybsy";
    inherit (darwin) CF configd;
    inherit passthruFun;
  };

  python37 = callPackage ./cpython {
    self = python37;
    sourceVersion = {
      major = "3";
      minor = "7";
      patch = "4";
      suffix = "";
    };
    sha256 = "0gxiv5617zd7dnqm5k9r4q2188lk327nf9jznwq9j6b8p0s92ygv";
    inherit (darwin) CF configd;
    inherit passthruFun;
  };

  pypy27 = callPackage ./pypy {
    self = pypy27;
    sourceVersion = {
      major = "6";
      minor = "0";
      patch = "0";
    };
    sha256 = "1qjwpc8n68sxxlfg36s5vn1h2gdfvvd6lxvr4lzbvfwhzrgqahsw";
    pythonVersion = "2.7";
    db = db.override { dbmSupport = true; };
    python = python27;
    inherit passthruFun;
  };

  pypy35 = callPackage ./pypy {
    self = pypy35;
    sourceVersion = {
      major = "6";
      minor = "0";
      patch = "0";
    };
    sha256 = "0lwq8nn0r5yj01bwmkk5p7xvvrp4s550l8184mkmn74d3gphrlwg";
    pythonVersion = "3.5";
    db = db.override { dbmSupport = true; };
    python = python27;
    inherit passthruFun;
  };

  pypy27_prebuilt = callPackage ./pypy/prebuilt.nix {
    # Not included at top-level
    self = pythonInterpreters.pypy27_prebuilt;
    sourceVersion = {
      major = "6";
      minor = "0";
      patch = "0";
    };
    sha256 = "0rxgnp3fm18b87ln8bbjr13g2fsf4ka4abkaim6m03y9lwmr9gvc"; # linux64
    pythonVersion = "2.7";
    inherit passthruFun;
    ncurses = ncurses5;
  };

  pypy35_prebuilt = callPackage ./pypy/prebuilt.nix {
  # Not included at top-level
    self = pythonInterpreters.pypy35_prebuilt;
    sourceVersion = {
      major = "6";
      minor = "0";
      patch = "0";
    };
    sha256 = "0j3h08s7wpglghasmym3baycpif5jshvmk9rpav4pwwy5clzmzsc"; # linux64
    pythonVersion = "3.5";
    inherit passthruFun;
    ncurses = ncurses5;
  };

})
