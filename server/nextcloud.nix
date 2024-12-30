{
  pkgs,
  modulesPath,
  config,
  ...
}:

{
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
    package = pkgs.nextcloud30;
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
    };

    maxUploadSize = "10G";

    extraApps = with pkgs.nextcloud30Packages.apps; {
      inherit
        registration
        calendar
        contacts
        end_to_end_encryption
        forms
        polls
        groupfolders
        twofactor_webauthn
        cookbook
        notes
        gpoddersync
        phonetrack
        ;
      files_retention = pkgs.fetchNextcloudApp {
        sha256 = "sha256-krJOb925AjmnwmkFYg00eC4KmICr4Tf3jUANYWTRJdA=";
        url = "https://github.com/nextcloud-releases/files_retention/releases/download/v1.19.0/files_retention-v1.19.0.tar.gz";
        license = "agpl3Only";
      };
      files_automatedtagging = pkgs.fetchNextcloudApp {
        sha256 = "sha256-eXLTCtdIW/D0nigyYKnHj9iFQNAxWs8F46vivCUgVYs=";
        url = "https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v1.20.0/files_automatedtagging-v1.20.0.tar.gz";
        license = "agpl3Only";
      };
      twofactor_admin = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud-releases/twofactor_admin/releases/download/v4.7.1/twofactor_admin.tar.gz";
        sha256 = "sha256-BJur/SKKXFTGsk5bALrdw+xOyr9lzT572Qpe1sMusfg=";
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

  services.nginx.defaultListenAddresses = [ "192.168.3.1" ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  system.stateVersion = "23.11";
}
