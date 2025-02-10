{ ... }:
{
  services.esphome = {
    enable = true;
    address = "0.0.0.0";

  };
  environment.persistence."/permament".directories = [ "/var/lib/private/esphome" ];
}
