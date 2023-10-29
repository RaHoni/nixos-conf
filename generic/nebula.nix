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
  services.nebula.networks."${netName}" = {
    enable = true;
    ca = config.sops.secrets."nebula/ca.crt".path;
    key = config.sops.secrets."nebula/${hostName}.key".path;
    cert = config.sops.secrets."nebula/${hostName}.crt".path;
    listen.port = 51821;
    lighthouses = [ "172.20.0.1" ];
    staticHostMap = {
      "172.20.0.1" = [
        "lighthouse.honermann.info:51821"
      ];
    };
    settings = {
      cipher = "aes";
      punchy = {
        punch = true;
        respond = true;
      };
    };
    firewall = lib.mkDefault {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          port = "any";
          proto = "icmp";
          host = "any";
        }
      ];
    };
  };
}
