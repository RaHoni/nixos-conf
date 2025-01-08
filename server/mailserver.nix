{
  config,
  lib,
  pkgs,
  sms,
  ...
}:
{
  imports = [
    sms
    ../generic/networking.nix
  ];

  networking = {
    firewall.enable = false;
    hostName = "mail";
    useHostResolvConf = lib.mkForce false;
    #useDHCP = lib.mkForce true;
    defaultGateway = {
      address = "169.254.26.129";
      interface = "eth0";
    };
    nameservers = [ "192.168.3.102" ];
    interfaces."eth0" = {
      ipv4.addresses = [
        {
          address = "169.254.26.130";
          prefixLength = 16;
        }
      ];
      ipv4.routes = [
        {
          address = "212.227.135.200";
          prefixLength = 32;
          via = "169.254.26.129";
        }
        {
          address = "192.168.2.0";
          prefixLength = 23;
          via = "169.254.26.129";
        }
      ];
    };
  };

  services.resolved.enable = true;

  #networking.wireguard.enable = true;
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.3/24" ];
    privateKeyFile = "/wireguard/wireguard-priv-key";
    peers = [
      {
        publicKey = "B/9Q2XAEEMsPlW60jdVMCiihJt85qzgWT3iN6ct7GiQ=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "212.227.135.200:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  mailserver = {
    enable = true;
    fqdn = "mail.honermann.info";
    domains = [ "honermann.info" ];

    loginAccounts = {
      "raoul@honermann.info" = {
        hashedPassword = "$2b$05$9HtR5GhDntgUrvDUBpJepuo5G8JSH7U8BSi44TJ13vVUj1PdpulCC";
        aliases = [ "webmaster@honermann.info" ];
      };
    };

    certificateScheme = "acme-nginx";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "raoul.honermann@web.de";
  };

  system.stateVersion = "24.11";
}
