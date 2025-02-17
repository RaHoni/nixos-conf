{ config, ... }:
let
  jellyfin = config.services.jellyfin;
in
{
  services.jellyfin = {
    enable = true;
  };

  users.users.jellyfin.extraGroups = [ "render" ];

  environment.persistence."/permament".directories = with jellyfin; [
    dataDir
    configDir
    logDir
  ];
}
