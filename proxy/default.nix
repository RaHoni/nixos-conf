{ lib, ... }:
{
  #proxmoxLXC.manageNetwork = lib.mkForce true;
  services.nginx.defaultListenAddresses = [ "192.168.3.207" ];
  imports = [ ../generic/proxy.nix ];

  services.automx2 = {
    enable = true;
    domain = "honermann.info";
    settings = {
      provider = "Fam. Honermann";
      domains = [ "honermann.info" ];
      servers = [
        {
          type = "imap";
          name = "mail.honermann.info";
        }
        {
          type = "smtp";
          name = "mail.honermann.info";
        }
      ];
    };
  };

  networking = {
    hostName = "ssl-proxy";
    enableIPv6 = true;
    useDHCP = lib.mkForce true;
    useNetworkd = lib.mkForce false;
    firewall = {
      allowPing = true;
      allowedTCPPorts = [
        80
        443
      ];
      #enable = lib.mkForce false;
    };
  };
  system.stateVersion = "23.11";
}
