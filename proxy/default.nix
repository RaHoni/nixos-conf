{ lib, ... }:
{
  proxmoxLXC.manageNetwork = lib.mkForce true;

  networking = {
    hostName = "ssl-proxy";
    enableIPv6 = true;
    useDHCP = lib.mkForce true;
    useNetworkd = lib.mkForce false;
    firewall = {
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      #enable = lib.mkForce false;
    };
  };
  system.stateVersion = "23.11";
}
