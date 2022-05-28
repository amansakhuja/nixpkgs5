{ lib, buildGoPackage, fetchFromGitHub, ronn, installShellFiles }:

buildGoPackage rec {
  pname = "git-lfs";
  version = "3.2.0";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "git-lfs";
    repo = "git-lfs";
    sha256 = "sha256-3gVUPfZs5GViEA3D7Zm5NdxhuEz9DhwPLoQqHFdGCrI=";
  };

  patches = [
    # patch git-lfs to install the git-lfs hook and configuration using the
    # absolute path to the git-lfs command. Doing so makes the git-lfs
    # installation pure as it won't depend on an impure PATH.
    ./refer-to-nixhack.SelfPath-to-access-the-git-lfs-comm.patch
  ];

  goPackagePath = "github.com/git-lfs/git-lfs";

  nativeBuildInputs = [ ronn installShellFiles ];

  ldflags = [ "-s" "-w" "-X ${goPackagePath}/config.Vendor=${version}" "-X ${goPackagePath}/config.GitCommit=${src.rev}" ];

  subPackages = [ "." ];

  preBuild = ''
    pushd go/src/github.com/git-lfs/git-lfs
      go generate ./commands
    popd
  '';

  postBuild = ''
    make -C go/src/${goPackagePath} man
  '';

  postInstall = ''
    installManPage go/src/${goPackagePath}/man/man*/*
  '';

  meta = with lib; {
    description = "Git extension for versioning large files";
    homepage    = "https://git-lfs.github.com/";
    changelog   = "https://github.com/git-lfs/git-lfs/raw/v${version}/CHANGELOG.md";
    license     = [ licenses.mit ];
    maintainers = [ maintainers.twey maintainers.marsam ];
  };
}
