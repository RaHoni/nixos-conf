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
    nameservers = [ "1.1.1.1" ];
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
      ];
    };
  };

  systemd.services."acme-mail.honermann.info" = {
    serviceConfig.ExecStartPre = [ "${pkgs.coreutils}/bin/sleep 120" ];
    path = [ pkgs.coreutils ];
  };

  services.resolved.enable = true;

  #networking.wireguard.enable = true;
  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.100.0.3/24"
      "2a01:239:2b9:9600::cafe:3/112"
    ];
    privateKeyFile = "/wireguard/wireguard-priv-key";
    peers = [
      {
        publicKey = "B/9Q2XAEEMsPlW60jdVMCiihJt85qzgWT3iN6ct7GiQ=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "212.227.135.200:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  mailserver = {
    enable = true;
    fqdn = "mail.honermann.info";
    domains = [ "honermann.info" ];

    extraVirtualAliases = {
      "abuse@honermann.info" = [ "raoul@honermann.info" ];
      "postmaster@honermann.info" = "raoul@honermann.info";
    };

    # Generate password with 'mkpasswd -m bcrypt'
    loginAccounts = {
      "raoul@honermann.info" = {
        hashedPassword = "$2b$05$XpvYiA47SAxYaFu8OVp7NOGOgpWUxEhis7czLSCE2ZgtVMk4pg9gu";
      };
      "server@honermann.info" = {
        hashedPassword = "$2b$05$HGJhaMaoCB8vYT9h1xyXwOGUoBd366bYzpgY9vse0ppMY2Hon7Imq";
        aliases = [
          "nextcloud@honermann.info"
          "noreply@honermann.info"
          "bacula@honermann.info"
          "hydra@honermann.info"
        ];
        sendOnly = true;
      };
      "christoph@honermann.info" = {
        hashedPassword = "$2b$05$Z5kw8mS2yCIrjBEW76mqH.SIZI2IATzbzOD9IiSWKXQ8LnuzNK4xS";
      };
      "sylvia@honermann.info" = {
        hashedPassword = "$2b$05$yP9Xnl3MrE.ucFyk4zaO2OEyraAbkhfOkjQOmLQzg1FUtnVDg6t4S";
      };
    };

    certificateScheme = "acme-nginx";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "raoul.honermann@web.de";
  };

  services.nginx.virtualHosts.rspamd = {
    listen = [
      {
        addr = "169.254.26.130";
        port = 80;
      }
    ];
    serverName = "rspamd.honermann.info";
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
      };
    };
  };

  system.stateVersion = "24.11";
}
