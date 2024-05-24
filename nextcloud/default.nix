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
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
      defaultPhoneRegion = "DE";
      extraTrustedDomains = [ "nextcloud.honermann.info" ];
    };

    maxUploadSize = "10G";


    extraApps = with pkgs.nextcloud28Packages.apps; {
      inherit registration calendar contacts end_to_end_encryption forms polls groupfolders twofactor_nextcloud_notification twofactor_webauthn cookbook;
      #twofactor_totp
      #   # onlyoffice
    };

    extraAppsEnable = true;

    https = true;
    config.trustedProxies = [ "192.168.3.207" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  system.stateVersion = "23.11";
}

