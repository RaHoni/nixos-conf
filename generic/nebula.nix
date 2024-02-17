{ config, lib, ... }:
let
  netName = "nebulaHonermann";
  hostName = "${config.networking.hostName}";
in
{
  sops.secrets."nebula/${hostName}.key" = {
    mode = "0440";
    owner = "nebula-${netName}";
    group = "nebula-${netName}";
    sopsFile = ../secrets/${hostName}/nebula.yaml;
  };
  sops.secrets."nebula/${hostName}.crt" = {
    mode = "0440";
    owner = "nebula-${netName}";
    group = "nebula-${netName}";
    sopsFile = ../secrets/${hostName}/nebula.yaml;
  };
  sops.secrets."nebula/ca.crt" = {
    mode = "0440";
    owner = "nebula-${netName}";
    group = "nebula-${netName}";
  };

  # nebula config
  services.nebula.networks."${netName}" = rec {
    enable = true;
    listen.port = lib.mkDefault 0;
    ca = config.sops.secrets."nebula/ca.crt".path;
    key = config.sops.secrets."nebula/${hostName}.key".path;
    cert = config.sops.secrets."nebula/${hostName}.crt".path;
    lighthouses = lib.mkIf (!config.services.nebula.networks."${netName}".isLighthouse) [ "172.20.0.1" ];
    staticHostMap = {
      "172.20.0.1" = [
        "lighthouse.honermann.info:123"
      ];
    };
    settings = {
      cipher = "aes";
      punchy = {
        punch = true;
        respond = true;
      };
    };
    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          port = 22;
          proto = "tcp";
          host = "any";
        }
        {
          port = "any";
          proto = "icmp";
          host = "any";
        }
      ];
    };
  };
}

