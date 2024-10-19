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
    package = pkgs.nextcloud29;
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
    };

    maxUploadSize = "10G";


    extraApps = with pkgs.nextcloud29Packages.apps; {
      inherit registration calendar contacts end_to_end_encryption forms polls groupfolders twofactor_nextcloud_notification twofactor_webauthn cookbook notes gpoddersync;
      files_retention = pkgs.fetchNextcloudApp {
        sha256 = "sha256-FazftNLLdxlnt7libXG4Ngyi6hyyxC2VhX/PXEard98=";
        url = "https://github.com/nextcloud-releases/files_retention/releases/download/v1.18.0/files_retention-v1.18.0.tar.gz";
        license = "agpl3Only";
      };
      files_automatedtagging = pkgs.fetchNextcloudApp {
        sha256 = "sha256-NeOJd3A3dZD86brdvDFyuQ1hGOo98C4T57aVhiUSMGg=";
        url = "https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v1.19.0/files_automatedtagging-v1.19.0.tar.gz";
        license = "agpl3Only";
      };
      phonetrack = pkgs.fetchNextcloudApp {
        sha256 = "sha256-V92f+FiS5vZEkq15A51pHoDpUOBfUOEVIcsXdP/rSMQ=";
        url = "https://github.com/julien-nc/phonetrack/releases/download/v0.8.1/phonetrack-0.8.1.tar.gz";
        license = "agpl3Only";
      };
      twofactor_admin = pkgs.fetchNextcloudApp {
      url = "https://github.com/nextcloud-releases/twofactor_admin/releases/download/v4.5.0/twofactor_admin.tar.gz";
      sha256 = "sha256-dDZ1MInaWTcl0Fo4gVBcgO887gHjUdV2RtUT43LqXW8=";
      license = "agpl3Only";
      };
      #twofactor_totp
      #   # onlyoffice
    };

    extraAppsEnable = true;

    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };

    https = true;
    settings = {
      trusted_proxies = [ "192.168.3.207" ];
      default_phone_region = "DE";
      trusted_domains = [ "nextcloud.honermann.info" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  system.stateVersion = "23.11";
}

