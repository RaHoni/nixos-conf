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

  users.users.jellyfin.extraGroups = [ "render" ];

  environment.persistence."/permament".directories = with jellyfin; [
    dataDir
    configDir
    logDir
    "/var/lib/private/jellyseerr/"
  ];
}
