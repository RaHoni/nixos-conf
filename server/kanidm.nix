{
  config,
  pkgs,
  sops,
  ...
}:
let
  secrets = config.sops.secrets;
in
{
  imports = [
    sops
    ../generic/modules
  ];
  networking = {
    hostName = "kanidm";
    defaultGateway.address = config.local.ips.gateway.ipv4.address;
    interfaces.eth0 = {
      ipv4.addresses = [
        config.local.ips.kanidm.ipv4
      ];
    };
  };

  nix.settings.extra-experimental-features = [
    "nix-command"
    "flakes"

  ];

  sops = {
    defaultSopsFile = ../secrets/server/kanidm.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true; # generate key above if it does not exist yet (has to be added manually to .sops.yaml)
      sshKeyPaths = [ ];
    };
    secrets = {
      admin_password.owner = "kanidm";
      idm_admin_password.owner = "kanidm";
      "nextcloud_service".owner = "kanidm";
      "audiobookshelf_service".owner = "kanidm";
      "headscale" = {
        owner = "kanidm";
        sopsFile = ../secrets/headscale.yaml;
      };
    };
  };

  users.users.kanidm = {
    uid = 999;
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_8;
    enableServer = true;
    serverSettings = {
      bindaddress = "0.0.0.0:443";
      ldapbindaddress = "0.0.0.0:3636";
      http_client_address_info.x-forward-for = [
        config.local.ips.ssl-proxy.ipv4.address
      ];
      version = "2";
      domain = "account.honermann.info";
      origin = "https://account.honermann.info";
      tls_key = "/var/lib/acme/account.honermann.info/key.pem";
      tls_chain = "/var/lib/acme/account.honermann.info/fullchain.pem";
    };
    provision = {
      enable = true;
      adminPasswordFile = secrets."admin_password".path;
      idmAdminPasswordFile = secrets."idm_admin_password".path;

      groups = {
        mail-server = { };
        jellyfin = { };
        jellyfin-admin = { };
        nextcloud = { };
        hass-admin = { };
        hass = { };
        headscale = { };
        family = { };
        messdiener = { };
        streaming = { };
        ferienfreizeit = { };
        nextcloud_admin = { };
        audiobookshelf = { };
        audiobookshelf_admin = { };
      };

      systems.oauth2 = {
        "audiobookshelf_service" = {
          displayName = "Audiobookshelf";
          originLanding = "https://hoerbuecher.honermann.info/audiobookshelf/auth/openid?callback=https://hoerbuecher.honermann.info/audiobookshelf/login/";
          originUrl = [
            "https://hoerbuecher.honermann.info/auth/openid/callback"
            "https://hoerbuecher.honermann.info/auth/openid/mobile-redirect"
          ];
          basicSecretFile = secrets.audiobookshelf_service.path;
          scopeMaps."audiobookshelf" = [
            "openid"
            "profile"
            "email"
          ];
        };
        headscale_service = {
          displayName = "Headscale";
          originLanding = "https://headscale.honermann.info/oidc/callback";
          originUrl = [ "https://headscale.honermann.info/oidc/callback" ];
          basicSecretFile = secrets.headscale.path;
          scopeMaps."headscale" = [
            "openid"
            "profile"
            "email"
          ];
        };
        "nextcloud_service" = {
          displayName = "Nextcloud main instance";
          originLanding = "https://honermann.info/apps/user_oidc/login/1";
          originUrl = [
            "https://honermann.info/apps/user_oidc/code"
            "https://nextcloud.honermann.info/apps/user_oidc/code"
          ];
          basicSecretFile = config.sops.secrets."nextcloud_service".path;
          scopeMaps."nextcloud" = [
            "openid"
            "profile"
            "email"
          ];
          claimMaps."groups".valuesByGroup = {
            "family" = [ "Familie" ];
            "messdiener" = [ "Messdiener" ];
            "ferienfreizeit" = [ "Ferienfreizeit" ];
            "streaming" = [ "Streaming" ];
            "nextcloud_admin" = [ "admin" ];
          };

        };
        homeassistant_service = {
          displayName = "Home Assistant";
          originLanding = "https://home.honermann.info/auth/oidc/welcome";
          originUrl = "https://home.honermann.info/auth/oidc/callback";
          public = true;
          scopeMaps."hass" = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
        };
      };

      persons = {
        "raoul" = {
          displayName = "Raoul";
          legalName = "Raoul Honermann";
          mailAddresses = [ "raoul@honermann.info" ];
          groups = [
            "family"
            "nextcloud"
            "nextcloud_admin"
            "jellyfin"
            "jellyfin-admin"
            "hass"
            "hass-admin"
            "headscale"

            "messdiener"
            "streaming"
            "ferienfreizeit"
            "audiobookshelf"
            "audiobookshelf_admin"
          ];
        };
        christoph = {
          displayName = "C.Honi";
          legalName = "Christoph Honermann";
          mailAddresses = [
            "christoph@honermann.info"
            "christoph.honermann@web.de"
          ];
          groups = [
            "family"
            "nextcloud"
            "audiobookshelf"
            "headscale"
            "hass"
            "hass-admin"
          ];
        };
        sylvia = {
          displayName = "Sylvia";
          legalName = "Sylvia Honermann";
          mailAddresses = [
            "sylvia@honermann.info"
            "sylvia.honermann@web.de"
          ];
          groups = [
            "family"
            "nextcloud"
            "audiobookshelf"
            "headscale"
            "hass"
          ];
        };
        stella = {
          displayName = "Stella";
          legalName = "Stella Honermann";
          mailAddresses = [ "stella.honermann@web.de" ];
          groups = [
            "family"
            "nextcloud"
            "audiobookshelf"
            "headscale"

            "messdiener"
          ];
        };
        maximilian = {
          displayName = "maximilian";
          legalName = "Maximilian Inckmann";
          mailAddresses = [ "maximilian@inckmann.de" ];
          groups = [
            "nextcloud"
            "audiobookshelf"
            "headscale"
          ];
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    443
    3636
  ];
  system.stateVersion = "25.05";
}
