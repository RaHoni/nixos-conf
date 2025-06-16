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
        files_retention
        files_automatedtagging
        previewgenerator
        twofactor_admin
        memories
        ;
      inherit (pkgs.unstable.nextcloud31Packages.apps) recognize;

    };

    extraAppsEnable = true;

    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };

    https = true;
    settings = {
      trusted_proxies = [ ips.ssl-proxy.ipv4 ];
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
