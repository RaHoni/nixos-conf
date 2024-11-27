{ config, lib, ... }:
{
  systemd.services."nebula@nebulaHonermann".serviceConfig = {
    AmbientCapabilities = lib.mkForce [
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_ADMIN"
    ];
    CapabilityBoundingSet = lib.mkForce [
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_ADMIN"
    ];
  };
  services.nebula.networks."nebulaHonermann" = {
    lighthouses = [ ];
    isLighthouse = true;
    listen.port = 123;
    settings = {
      lighthouse = {
        serve_dns = true;
        dns = {
          host = "0.0.0.0";
          port = 53;
        };
      };
    };
  };
}
