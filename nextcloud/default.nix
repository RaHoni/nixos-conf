{ pkgs, modulesPath, config, ... }:

{
  networking.hostName = "nextcloud";
  sops.secrets = {
    adminpass = {
      sopsFile = ../secrets/nextcloud/secrets.yaml;
    };
  };

  services.nextcloud = {
    enable = true;
    datadir = "/var/data";
    package = pkgs.nextcloud28;
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.adminpass.path;
      defaultPhoneRegion = "DE";
    };

    maxUploadSize = "10G";


    extraApps = with pkgs.nextcloud28Packages.apps; {
      inherit mail calendar       contacts      end_to_end_encryption            forms      polls            groupfolders      impersonate                twofactor_nextcloud_notification      twofactor_webauthn;
      #twofactor_totp
      #   # onlyoffice
    };

    https = true;
    config.trustedProxies = [ "nextcloud.honermann.info" "honermann.info" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  system.stateVersion = "23.11";
}

