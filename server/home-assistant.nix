{ pkgs, config, ... }:
let
  serviceName = config.virtualisation.oci-containers.containers.homeassistant.serviceName;
in
{

  virtualisation.oci-containers.containers.homeassistant = {
    volumes = [
      "home-assistant:/config"
      "home-assistant-media:/media"
    ];
    environment.TZ = "Europe/Berlin";
    pull = "newer";
    image = "ghcr.io/home-assistant/home-assistant:stable";
    networks = [ "podman:mac=52:31:65:81:c8:fd" ];
    devices = [ "/dev/ttyACM0:/dev/ttyACM0" ]; # ZigBee stick
  };

  systemd.services."${serviceName}" = {
    wants = [
      "container@proxy.service"
      "phpfpm-nextcloud.service"
    ];
    after = [
      "container@proxy.service"
      "phpfpm-nextcloud.service"
    ];
  };
}
