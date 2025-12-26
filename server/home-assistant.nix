{ pkgs, config, ... }:
let
  serviceName = config.virtualisation.oci-containers.containers.homeassistant.serviceName;
in
{
  services.wyoming = {
    faster-whisper.servers."German" = {
      enable = true;
      language = "de";
      model = "medium-int8";
      beamSize = 3;
      uri = "tcp://0.0.0.0:10300";
    };
    openwakeword = {
      enable = true;
    };
    piper.servers."German" = {
      enable = true;
      voice = "de_DE-thorsten-medium";
      uri = "tcp://0.0.0.0:10200";
    };
  };

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

  networking.firewall.allowedUDPPorts = [ 1900 ]; # SSDP
  networking.firewall.allowedTCPPorts = [
    8123 # Webinterface
    10200
    10300
    10400
  ];
}
