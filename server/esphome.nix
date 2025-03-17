{ ... }:
{
  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    openFirewall = true;
  };
  environment.persistence."/permament".directories = [ "/var/lib/private/esphome" ];
}
