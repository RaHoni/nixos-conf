{
  pkgs,
  modulesPath,
  config,
  ...
}:
let
  cfg = config.services.nextcloud;
  occ = config.services.nextcloud.occ;
  oidc_client_id = "nextcloud_service";
  ips = config.myModules.ips;
in
{
  sops.secrets = {
    nextcloud_service = {
      sopsFile = ../secrets/server/kanidm.yaml;
    };
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
    package = pkgs.nextcloud32;
    hostName = "honermann.info";
    configureRedis = true;
    database.createLocally = true;

    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.adminpass.path;
    };

    maxUploadSize = "10G";

    extraApps = with cfg.package.packages.apps; {
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
        user_oidc
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
        url = "https://github.com/nextcloud-releases/workflow_script/releases/download/v3.0.0/workflow_script-v3.0.0.tar.gz";
        sha256 = "sha256-xP7BmMsBg2rg+BvegjJ2ke/RIQFlIgYGGs7OT3ZZH+I=";
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

      #OIDC related
      allow_local_remote_servers = true;
      allow_user_to_change_display_name = false;
      user_oidc = {
        login_label = "Login with Honermann Account";
        single_logout = false; # not supported by Kanidm yet, see https://github.com/kanidm/kanidm/issues/1997
      };

    };
  };

  #OIDC provider automatic provisioning
  #from https://github.com/JulianFP/NixOSConfig/blob/main/mainserver/nextcloud/configuration.nix
  sops.templates."nextcloud-oidc-setup-script" = {
    mode = "0500";
    content = ''
      nextcloud-occ user_oidc:provider "Honermann Account" --clientid="${oidc_client_id}" --clientsecret="${
        config.sops.placeholder."${oidc_client_id}"
      }" --discoveryuri="https://account.honermann.info/oauth2/openid/${oidc_client_id}/.well-known/openid-configuration" --mapping-uid="name" --unique-uid=0 --group-provisioning=1 --check-bearer=1 --bearer-provisioning=1
    '';
  };
  systemd.services.nextcloud-custom-setup = {
    wants = [ "container@kanidm.service" ];
    after = [
      "nextcloud-setup.service"
      "container@kanidm.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [
      occ
      pkgs.bash
    ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/sh ${config.sops.templates."nextcloud-oidc-setup-script".path}";
    };
  };

  services.nginx.defaultListenAddresses = [ ips.server.ipv4.address ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  system.stateVersion = "23.11";
}
