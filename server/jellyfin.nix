{ config, ... }:
let
  jellyfin = config.services.jellyfin;
  jellyseerr = config.services.jellyseerr;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts = {
    sonarr = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8090;
        }
      ];
      locations."/" = {
        proxyPass = "http://unix:/var/nginx/sonarr.sock";
      };
    };
    radarr = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8091;
        }
      ];
      locations."/" = {
        proxyPass = "http://unix:/var/nginx/radarr.sock";
      };
    };
    jackett = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8092;
        }
      ];
      locations."/".proxyPass = "http://unix:/var/nginx/jackett.sock";
    };
  };

  networking.firewall.allowedTCPPorts = [
    8090
    8091
    8092
  ];

  users.users.jellyfin.extraGroups = [ "render" ];

  myModules.folder.folders = with jellyfin; {
    "${dataDir}" = { };
    "${configDir}" = { };
    "${logDir}" = { };
    "/var/lib/private/jellyseerr/" = { };
  };
}
