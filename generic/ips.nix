{ config, ... }:
{
  local.ips = rec {
    server = {
      # Nextcloud uses the same port as server since it uses nginx
      ipv4 = "192.168.3.1";
      ipv6 = "fd00::4:1";
      bacula = {
        inherit (server) ipv4 ipv6;
      };
    };
    "pi.hole" = {
      ipv4 = "192.168.3.12";
      ipv6 = "fd00::4:102";
    };
    audiobookshelf = {
      ipv4 = "192.168.3.209";
      ipv6 = "fd00::4:209";
    };
    binarycache = {
      inherit (server) ipv4 ipv6;
    };
    hydra = {
      inherit (server) ipv4 ipv6;
    };
  };
}
