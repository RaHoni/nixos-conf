{ pkgs, ... }:
{
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unstable.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
  };
  environment.persistence."/permament".directories = [
    "/var/lib/unifi/"
  ];

  networking.firewall.allowedTCPPorts = [ 8443 ];
}
