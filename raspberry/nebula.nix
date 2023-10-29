{ config, ... }:
{
  services.nebula.networks."nebulaHonermann".seetings = {
    lighthouse.dns = {
      host = "0.0.0.0";
      port = 53;
    };
  };
}
