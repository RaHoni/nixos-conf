{ pkgs, modulesPath, ... }:

{

  services.nextcloud = {
    enable = true;
    #    datadir = "/var/data";
    package = pkgs.nextcloud27;
    hostName = "192.168.2.105";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
      defaultPhoneRegion = "DE";
    };

    maxUploadSize = "10G";


    # extraApps = with pkgs.nextcloud27Packages.apps; [
    #   mail
    #   calendar
    #   contacts
    #   # deck
    #   # notes
    #   # tasks
    #   # forms
    #   # polls
    #   # files_markdown
    #   # groupfolders
    #   # impersonate
    #   # previewgenerator
    #   # twofactor_nextcloud_notification
    #   # twofactor_webauthn
    #   # onlyoffice
    # ];

    # https = true;
    # trustedProxies = [ "" ];
  };
}

