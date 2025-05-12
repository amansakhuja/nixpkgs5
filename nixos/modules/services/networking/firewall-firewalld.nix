{ config, lib, ... }:

let
  cfg = config.networking.firewall;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "firewalld") {
    assertions = [
      {
        assertion = cfg.interfaces == { };
        message = ''
          Per interface configurations is not supported with the firewalld
          based firewall. Create zone files instead.
        '';
      }
    ];
    services.firewalld = {
      settings = {
        DefaultZone = lib.mkDefault "nixos-fw-default";
        LogDenied =
          if cfg.logRefusedConnections then
            (if cfg.logRefusedUnicastsOnly then "unicast" else "all")
          else
            "off";
      };
      zones = {
        nixos-fw-default = {
          target = if cfg.rejectPackets then "%%REJECT%%" else "DROP";
          icmpBlockInversion = true;
          icmpBlocks = lib.mkIf cfg.allowPing [ "echo-request" ];
          ports =
            let
              f = protocol: port: { inherit protocol port; };
              tcpPorts = map (f "tcp") (cfg.allowedTCPPorts ++ cfg.allowedTCPPortRanges);
              udpPorts = map (f "udp") (cfg.allowedUDPPorts ++ cfg.allowedUDPPortRanges);
            in
            tcpPorts ++ udpPorts;
        };
        trusted.interfaces = cfg.trustedInterfaces;
      };
    };
  };
}
