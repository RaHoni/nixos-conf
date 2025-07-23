{
  pkgs,
  modulesPath,
  config,
  ...
}:
let
  ips = config.local.ips;
in
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
    package = pkgs.nextcloud31;
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
    };

    maxUploadSize = "10G";

    extraApps = with pkgs.nextcloud31Packages.apps; {
      inherit
        calendar
        contacts
        cookbook
        end_to_end_encryption
        files_automatedtagging
        files_retention
        forms
        gpoddersync
        groupfolders
        memories
        notes
        phonetrack
        polls
        previewgenerator
        recognize
        registration
        twofactor_admin
        twofactor_webauthn
        ;

      workflow_script = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud-releases/workflow_script/releases/download/v2.0.0/workflow_script-v2.0.0.tar.gz";
        sha256 = "sha256-x6PoQsesQzhoOeTTbIG6FiL6pmpfAXScFF9SMtwIXsQ=";
        license = "agpl3Only";
      };

    };

    extraAppsEnable = true;

    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };

    https = true;
    settings = {
      trusted_proxies = (map (addr: addr.address) config.networking.interfaces.eth0.ipv4.addresses);
      default_phone_region = "DE";
      trusted_domains = [ "nextcloud.honermann.info" ];
    };
  };

  services.nginx.defaultListenAddresses = [ ips.server.ipv4 ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  system.stateVersion = "23.11";
}
