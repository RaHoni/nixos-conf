{ pkgs, modulesPath, config, ... }:

{
  networking.hostName = "nextcloud";
  sops.secrets = {
    adminpass = {
      sopsFile = ../secrets/nextcloud/secrets.yaml;
      owner = config.users.users.nextcloud.name;
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/data 770 nextcloud nextcloud"
  ];

  services.nextcloud = {
    enable = true;
    datadir = "/var/data";
    package = pkgs.nextcloud28;
    hostName = "nextcloud.honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
    };

    maxUploadSize = "10G";


    extraApps = with pkgs.nextcloud28Packages.apps; {
      inherit registration calendar contacts end_to_end_encryption forms polls groupfolders twofactor_nextcloud_notification twofactor_webauthn cookbook notes gpoddersync;
      files_retention = pkgs.fetchNextcloudApp {
        sha256 = "sha256-a+0veb5J/9BhkG35SnKf2yBMKVSRmapo6LyEhc+io7k=";
        url = "https://github.com/nextcloud-releases/files_retention/releases/download/v1.17.2/files_retention-v1.17.2.tar.gz";
        license = "agpl3Only";
      };
      files_automatedtagging = pkgs.fetchNextcloudApp {
        sha256 = "sha256-bL9j8dnkyBBFU+7T1VhjGaQoexzN3AbK4+ykIbCLyRg=";
        url = "https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v1.18.0/files_automatedtagging-v1.18.0.tar.gz";
        license = "agpl3Only";
      };
      #twofactor_totp
      #   # onlyoffice
    };

    extraAppsEnable = true;

    https = true;
    settings = {
      trustedProxies = [ "192.168.3.207" ];
      defaultPhoneRegion = "DE";
      extraTrustedDomains = [ "nextcloud.honermann.info" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  system.stateVersion = "23.11";
}

