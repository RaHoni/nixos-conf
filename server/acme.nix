{ config, ... }:
{
  sops.secrets.cloudflare.sopsFile = ../secrets/server/kanidm.yaml;
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@honermann.info";
    certs = {
      "mail.honermann.info" = {
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.cloudflare.path;
      };
    };
  };

}
