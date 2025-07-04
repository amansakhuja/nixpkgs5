{
  config,
  hostPkgs,
  lib,
  ...
}:
let
  inherit (lib) types mkOption;

  inherit (hostPkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  options = {
    passthru = mkOption {
      type = types.lazyAttrsOf types.raw;
      description = ''
        Attributes to add to the returned derivations,
        which are not necessarily part of the build.

        This is a bit like doing `drv // { myAttr = true; }` (which would be lost by `overrideAttrs`).
        It does not change the actual derivation, but adds the attribute nonetheless, so that
        consumers of what would be `drv` have more information.
      '';
    };

    enableDebugHook = lib.mkEnableOption "" // {
      description = ''
        debugging hooks in the sandbox.

        TODO: short description how to use and reference to real docs.
      '';
    };

    rawTestDerivation = mkOption {
      type = types.package;
      description = ''
        Unfiltered version of `test`, for troubleshooting the test framework and `testBuildFailure` in the test framework's test suite.
        This is not intended for general use. Use `test` instead.
      '';
      internal = true;
    };

    test = mkOption {
      type = types.package;
      # TODO: can the interactive driver be configured to access the network?
      description = ''
        Derivation that runs the test as its "build" process.

        This implies that NixOS tests run isolated from the network, making them
        more dependable.
      '';
    };
  };

  config = {
    rawTestDerivation =
      assert lib.assertMsg (config.sshBackdoor.enable -> isLinux)
        "The SSH backdoor is not supported for macOS host systems!";

      assert lib.assertMsg (config.enableDebugHook -> isLinux)
        "The debugging hook is not supported for macOS host systems!";

      hostPkgs.stdenv.mkDerivation {
        name = "vm-test-run-${config.name}";

        requiredSystemFeatures =
          [ "nixos-test" ]
          ++ lib.optional isLinux "kvm"
          ++ lib.optional isDarwin "apple-virt";

        nativeBuildInputs = lib.optionals config.enableDebugHook [
          hostPkgs.openssh
          hostPkgs.inetutils
        ];

        buildCommand = ''
          mkdir -p $out

          # effectively mute the XMLLogger
          export LOGFILE=/dev/null

          ${lib.optionalString config.enableDebugHook ''
            ln -sf \
              ${hostPkgs.systemd}/lib/systemd/ssh_config.d/20-systemd-ssh-proxy.conf \
              ssh_config
          ''}

          ${config.driver}/bin/nixos-test-driver \
            -o $out \
            ${lib.optionalString config.enableDebugHook "--debug-hook"}
        '';

        passthru = config.passthru;

        meta = config.meta;
      };
    test = lib.lazyDerivation {
      # lazyDerivation improves performance when only passthru items and/or meta are used.
      derivation = config.rawTestDerivation;
      inherit (config) passthru meta;
    };

    # useful for inspection (debugging / exploration)
    passthru.config = config;
  };
}
