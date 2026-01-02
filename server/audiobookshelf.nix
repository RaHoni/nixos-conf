{ pkgs, ... }:
{
  services.audiobookshelf = {
    enable = true;
    # package = pkgs.unstable.audiobookshelf;
    openFirewall = true;
    host = "0.0.0.0";
  };
  systemd.services.audiobookshelf = rec {
    wants = [ "container@kanidm.service" ];
    after = wants;
  };
}
