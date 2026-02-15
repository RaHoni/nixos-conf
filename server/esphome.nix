{ ... }:
{
  services.esphome = {
    enable = true;
    address = "0.0.0.0";
    openFirewall = true;
  };
  myModules.folder.folders."/var/lib/private/esphome" = { };
}
