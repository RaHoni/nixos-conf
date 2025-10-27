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
  imports = [ sops ];
  networking.hostName = "kanidm";

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
        sopsFile = ../secrets/server/headscale.yaml;
      };
    };
  };

  users.users.kanidm = {
    uid = 999;
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_7;
    enableServer = true;
    serverSettings = {
      bindaddress = "0.0.0.0:443";
      ldapbindaddress = "169.253.26.1:3636";
      http_client_address_info.proxy-v2 = [
        "169.254.26.100"
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
          originLanding = "https://hoerbuecher.honermann.info/audiobookshelf/auth/openid/callback";
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
          originUrl = "https://honermann.info/apps/user_oidc/code";
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
          ];
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    443
    3636
  ];
}
