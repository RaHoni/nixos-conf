{ config, lib, ... }:
{
  imports = [ ../generic/ips.nix ];
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
          host = "192.168.3.208";
          port = 53;
        };
      };
    };
  };
}
