{ config, ... }:
{
  services.nebula.networks."nebulaHonermann" = {
    lighthouses = [ ];
    isLighthouse = true;
    seetings = {
      lighthouse.dns = {
        host = "0.0.0.0";
        port = 53;
      };
    };
  }
