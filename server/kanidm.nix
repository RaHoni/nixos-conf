{
  config,
  pkgs,
  sops,
  ...
}:

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
      cloudflare = { };
      admin_password.owner = "kanidm";
      idm_admin_password.owner = "kanidm";
      "nextcloud_service".owner = "kanidm";
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@honermann.info";
    certs."account.honermann.info" = {
      group = "kanidm";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cloudflare.path;
    };
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning;
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
      adminPasswordFile = config.sops.secrets."admin_password".path;
      idmAdminPasswordFile = config.sops.secrets."idm_admin_password".path;

      groups = {
        mail-server = { };
        jellyfin = { };
        jellyfin-admin = { };
        nextcloud = { };
        hass-admin = { };
        hass = { };
        family = { };
      };

      systems.oauth2."nextcloud_service" = {
        displayName = "Nextcloud main instance";
        originLanding = "https://honermann.info/apps/user_oidc/login/1";
        originUrl = "https://honermann.info/apps/user_oidc/code";
        basicSecretFile = config.sops.secrets."nextcloud_service".path;
        scopeMaps."nextcloud" = [
          "openid"
          "profile"
          "email"
        ];
      };

      persons = {
        "raoul" = {
          displayName = "Raoul";
          legalName = "Raoul honermann";
          mailAddresses = [ "raoul@honermann.info" ];
          groups = [
            "family"
            "nextcloud"
            "jellyfin"
            "jellyfin-admin"
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
