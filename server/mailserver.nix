{
  config,
  lib,
  inputs,
  ...
}:
let
  certPath = "/var/lib/acme/${config.mailserver.fqdn}";
  ips = config.local.ips;
  vpsipv4 = ips.vps.ipv4.address;
  serverIPv4 = ips.server.ipv4.address;
  mail = config.mailserver;
in
{
  imports = [
    inputs.simple-mail-server.nixosModules.mailserver
    ../generic/networking.nix
    ../generic/modules
  ];

  networking = {
    firewall.enable = false;
    hostName = "mail";
    useHostResolvConf = lib.mkForce false;
    useDHCP = lib.mkForce true;
    nameservers = [ "1.1.1.1" ];
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
        endpoint = "${vpsipv4}:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.honermann.info";
    domains = [ "honermann.info" ];
    enableManageSieve = true;

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

    certificateScheme = "manual";
    certificateFile = "${certPath}/fullchain.pem";
    keyFile = "${certPath}/key.pem";
  };

  services.restic.backups.mail = {
    repository = "rest:http://${serverIPv4}:8080/raoul/server";
    passwordFile = "/resticPass";
    environmentFile = "/restic-http-conf";
    timerConfig = {
      OnCalendar = "23:00";
      Persistent = true;
    };
    paths = [
      mail.mailDirectory
      mail.sieveDirectory
      mail.dkimKeyDirectory
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
  };

  services.nginx.virtualHosts.rspamd = {
    listen = [
      {
        addr = "0.0.0.0";
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
