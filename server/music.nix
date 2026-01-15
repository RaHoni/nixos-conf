{
  config,
  pkgs,
  ...
}:
let
  ips = config.myModules.ips;
in
{
  imports = [ ../generic/modules ];
  networking = {
    hostName = "music";
    nameservers = [
      ips."pi.hole".ipv4.address
      ips."pi.hole".ipv6.address
      ips.cloudflare.ipv4.address
      ips.cloudflare.ipv6.address
    ];
    defaultGateway = ips.gateway.ipv4.address;
    interfaces.eth0.ipv4 = {
      addresses = [ ips.music.ipv4 ];
    };
  };
  system.stateVersion = "25.11";

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

  services = {
    avahi = {
      enable = true;
      openFirewall = true;
      reflector = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    music-assistant = {
      enable = true;
      package = pkgs.music-assistant;
      providers = [
        "snapcast"
        "radiobrowser"
        "hass"
        "audiobookshelf" # only unstable
        "hass_players"
        "jellyfin"
        "theaudiodb"
        "builtin"
        "builtin_player"
      ];
    };
    snapserver = {
      enable = true;
      openFirewall = true;
      settings = {
        tcp.enabled = true;
        stream.source = [
          "librespot://${pkgs.librespot}/bin/librespot?name=Spotify&devicename=Snapcast&params=-z%2050000"
          "airplay://${pkgs.shairport-sync}/bin/shairport-sync?name=Airplay"
        ];
      };
    };
  };
  systemd.services.music-assistant.path = [ pkgs.snapcast ];

  networking.firewall = {
    allowedUDPPorts = [
      6001 # airplay
      6002
      6003
    ];
    allowedTCPPorts = [
      50000 # librespot
      50001 # librespot2
      5000 # airplay
      4444

      # wyoming
      10200
      10300
      10400

      # music-assistant
      8095
      8097
    ];
  };

}
