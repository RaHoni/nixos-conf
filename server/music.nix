{
  config,
  pkgs,
  inputs,
  ...
}:
{
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
      package = pkgs.unstable.music-assistant;
      providers = [
        "snapcast"
        "radiobrowser"
        "hass"
        "audiobookshelf" # only unstable
        "hass_players"
        "jellyfin"
        "player_group"
        "theaudiodb"
      ];
    };
    snapserver = {
      enable = true;
      openFirewall = true;
      streams = {
        spotify = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            params = "-z 50000 -i \"192.168.1.200\" "; # listen Port
          };
        };

        airplay = {
          type = "airplay";
          location = "${pkgs.shairport-sync}/bin/shairport-sync";
        };
      };
    };
  };
  systemd.services.music-assistant.path = [ pkgs.snapcast ];

  environment.persistence."/permament".directories = [
    "/var/lib/private/snapserver"
    "/var/lib/private/music-assistant"
  ];

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

      # music-assistant
      8095
      8097
    ];
  };

}
