{ config, ... }:
let
  jellyfin = config.services.jellyfin;
in
{
  services.jellyfin = {
    enable = true;
  };

  environment.persistence."/permament".directories = with jellyfin; [
    dataDir
    configDir
    logDir
  ];
}
