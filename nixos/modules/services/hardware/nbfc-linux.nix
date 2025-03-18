{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nbfc-linux;

  nbfcConfigList = lib.splitString "\n" (
    lib.removeSuffix "\n" (
      builtins.readFile (
        pkgs.runCommand "nbfc-config-list" { } ''
          ${pkgs.nbfc-linux}/bin/nbfc config --list > $out
        ''
      )
    )
  );
in
{
  options.services.nbfc-linux = {
    enable = lib.mkEnableOption "NBFC: NoteBook FanControl service";

    configName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The NBFC configuration name to use. Obtain the list via `nbfc config --list`";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = (cfg.configName == null) || (builtins.elem cfg.configName nbfcConfigList);
        message = "nbfc-linux: invalid configName: ${cfg.configName}";
      }
    ];

    environment.systemPackages = [ pkgs.nbfc-linux ];

    systemd.services.nbfc-linux = {
      description = "NoteBook FanControl";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file ${
          pkgs.writeText "nbfc-config.json" (lib.strings.toJSON { SelectedConfigId = cfg.configName; })
        }";
      };
      path = [ pkgs.kmod ];
    };
  };
}
