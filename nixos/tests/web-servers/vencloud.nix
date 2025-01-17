import ../make-test-python.nix (
  { lib, pkgs, ... }:
  {
    name = "vencloud";
    meta.maintainers = with lib.maintainers; [ eveeifyeve ];

    nodes.server = {
      services.vencloud = {
        enable = true;
        settings = {
          REDIS_URL = "redis://redis:vencloud@localhost:6379";
        };
      };

      services.redis.servers."vencloud-redis" = {
        enable = true;
        openFirewall = true;
      };
    };

    testScript = ''
      server.start()
      server.wait_for_unit("vencloud.service" "vencloud-redis.service")
      server.wait_for_open_port(8080)
      server.succeed("curl --fail http://localhost:8080/")
    '';
  }
)
