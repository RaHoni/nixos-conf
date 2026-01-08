{ config, ... }:
{
  sops.secrets.htpasswd = {
    sopsFile = ../secrets/server/restic.yaml;
    owner = "restic";
  };
  services.restic.server = {
    enable = true;
    privateRepos = true;
    dataDir = "/restic";
    htpasswd-file = config.sops.secrets.htpasswd.path;
    listenAddress = "8080";
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
