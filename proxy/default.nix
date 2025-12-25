{
  lib,
  config,
  cloudflare-api-key,
  ...
}:
{
  #proxmoxLXC.manageNetwork = lib.mkForce true;
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

  services.cloudflare-dyndns = {
    enable = true;
    ipv4 = false;
    ipv6 = true;
    domains = [ "honermann.info" ];
    apiTokenFile = cloudflare-api-key;
  };

  networking = {
    hostName = "ssl-proxy";
    enableIPv6 = true;
    useDHCP = lib.mkForce true;
    useHostResolvConf = false;
    tempAddresses = "disabled";
    interfaces.eth0 = {
      macAddress = "2a:42:d6:d4:b8:20";
      useDHCP = true;
    };
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
