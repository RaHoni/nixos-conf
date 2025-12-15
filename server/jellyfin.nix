{ config, ... }:
let
  jellyfin = config.services.jellyfin;
  jellyseerr = config.services.jellyseerr;
in
{
  services.jellyfin = {
    enable = true;
  };

  services.jellyseerr = {
    enable = true;
  };

  services.nginx.virtualHosts = {
    sonarr = {
      listen = [
        {
          addr = "127.0.0.1";
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
          addr = "127.0.0.1";
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
          addr = "127.0.0.1";
          port = 8092;
        }
      ];
      locations."/".proxyPass = "http://unix:/var/nginx/jackett.sock";
    };
  };

  users.users.jellyfin.extraGroups = [ "render" ];

  environment.persistence."/permament".directories = with jellyfin; [
    dataDir
    configDir
    logDir
    "/var/lib/private/jellyseerr/"
  ];
}
