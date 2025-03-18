{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

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

    environment.etc."nbfc-linux/config.json".source = pkgs.writeTextFile {
      name = "nbfc-linux-config.json";
      text = ''{"SelectedConfigId": "${cfg.configName}"}'';
    };

    systemd.services.nbfc-linux = {
      enable = true;
      description = "NoteBook FanControl";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
      path = [ pkgs.kmod ];
      script = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file /etc/nbfc-linux/config.json";
    };
  };
}
