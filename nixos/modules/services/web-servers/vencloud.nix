{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
  cfg = config.services.vencloud;
  settingsFormat = pkgs.formats.keyValue { };
in
{
  meta.doc = ./vencloud.md;
  meta.maintainers = with lib.maintainers; [ eveeifyeve ];

  options.services.vencloud = {
    enable = mkEnableOption "Selfhosted vencloud api";

    package = mkPackageOption pkgs "vencloud" { };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;

        options = {
          DISCORD_CLIENT_ID = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 321436435432;
            description = "The client ID that should be used for Discord OAuth.";
          };

          DISCORD_CLIENT_SECRET = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = 352364526452;
            description = "The client secret that should be used for Discord OAuth.";
          };

          DISCORD_REDIRECT_URI = mkOption {
            type = types.nullOr types.str;
            default = "http://localhost:8000/v1/oauth/callback";
            example = "https://example.com/v1/oauth/callback";
            description = "The redirect URI that should be used for Discord OAuth.";
          };

          HOST = mkOption {
            type = types.nullOr types.str;
            default = "0.0.0.0";
            description = "The host that Vencloud should listen on.";
          };

          PORT = mkOption {
            type = types.nullOr types.port;
            default = null;
            description = "The port that Vencloud should listen on.";
          };

          REDIS_URI = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The Redis server address to use for Vencloud.";
          };
        };
      };
      default = { };

      description = ''
        Configuration for Vencloud, exported as environment variables.
        See
        <link xlink:href="https://github.com/Vencord/Vencloud/blob/main/.env.example"/>
        for supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.vencloud = {
      description = "Vencord's API for cloud settings sync";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = cfg.settings;
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        ExecStart = lib.getExe cfg.package;
      };
    };
  };

}
