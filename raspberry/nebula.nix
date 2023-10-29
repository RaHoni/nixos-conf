{ config, lib, ... }:
{
  services.nebula.networks."nebulaHonermann" = {
    lighthouses = [ ];
    isLighthouse = true;
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
