{ config, lib, ... }:
{
  sops.secrets.cloudflare.sopsFile = ../secrets/server/kanidm.yaml;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@honermann.info";
      group = "nginx";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cloudflare.path;
    };
    certs =
      (lib.genAttrs (map (subdomain: (if subdomain == "" then "" else "${subdomain}.") + "honermann.info")
        [
          ""
          "account"
          "anfragen"
          "binarycache"
          "headscale"
          "hoerbuecher"
          "home"
          "hydra"
          "karaoke"
          "media"
          "autoconfig"
        ]
      ) (n: { }))
      // {
        "honermann.info" = {
          extraDomainNames = [ "nextcloud.honermann.info" ];
        };
        "autoconfig.honermann.info".extraDomainNames = [ "autodiscover.honermann.info" ];
      };
  };

}
