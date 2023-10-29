{ config, lib, ... }:
{
  services.nebula.networks."nebulaHonermann" = {
    lighthouses = [ ];
    isLighthouse = true;
    settings = {
      lighthouse.dns = {
        host = "0.0.0.0";
        port = 53;
      };
    };
  };
}
