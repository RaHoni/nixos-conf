{ pkgs, ... }:
{
  services.wyoming = {
    faster-whisper.servers."German" = {
      enable = true;
      language = "de";
      model = "base";
      beamSize = 3;
      uri = "tcp://0.0.0.0:10300";
    };
    openwakeword = {
      enable = true;
      preloadModels = [
        "hey_jarvis"
        "ok_nabu"
        "hey_rhasspy"
      ];
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
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
    extraOptions = [
      "--network=host"
      "--device=/dev/ttyACM0:/dev/ttyACM0" # ZigBee stick
    ];
  };

  networking.firewall.allowedUDPPorts = [ 1900 ]; # SSDP
  networking.firewall.allowedTCPPorts = [
    10200
    10300
    10400
  ];
}
