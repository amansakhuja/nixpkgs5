{
  lib,
  fetchFromGitLab,
  rustPlatform,
  llvmPackages,
  pkg-config,
  xen-slim,
}:

rustPlatform.buildRustPackage {
  pname = "xen-guest-agent";
  version = "0.4.0-unstable-2024-05-31";

  src = fetchFromGitLab {
    owner = "xen-project";
    repo = "xen-guest-agent";
    rev = "03aaadbe030f303b1503e172ee2abb6d0cab7ac6";
    hash = "sha256-OhzRsRwDvt0Ov+nLxQSP87G3RDYSLREMz2w9pPtSUYg=";
  };

  cargoHash = "sha256-E6QKh4FFr6sLAByU5n6sLppFwPHSKtKffhQ7FfdXAu4=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    llvmPackages.clang
    pkg-config
  ];

  buildInputs = [ xen-slim ];

  # Install the sample systemd service.
  postInstall = ''
    install -Dm644 startup/xen-guest-agent.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/xen-guest-agent.service \
      --replace-fail "/usr/sbin/xen-guest-agent" "$out/bin/xen-guest-agent"
  '';

  # Add the Xen libraries in the runpath so the guest agent can find libxenstore.
  postFixup = "patchelf $out/bin/xen-guest-agent --add-rpath ${xen-slim.out}/lib";

  meta = {
    description = "Xen agent running in Linux/BSDs (POSIX) VMs";
    homepage = "https://gitlab.com/xen-project/xen-guest-agent";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      matdibu
      sigmasquadron
    ];
    mainProgram = "xen-guest-agent";
  };
}
