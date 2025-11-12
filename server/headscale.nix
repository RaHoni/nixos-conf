{ config, ... }:
{
  sops.secrets.headscale = {
    sopsFile = ../secrets/server/headscale.yaml;
    owner = "headscale";
  };
  services.headscale = {
    enable = true;
    port = 8081;
    settings = {
      oidc = rec {
        client_id = "headscale_service";
        client_secret_path = config.sops.secrets.headscale.path;
        issuer = "https://account.honermann.info/oauth2/openid/${client_id}";
        pkce.enabled = true;
      };
      server_url = "https://headscale.honermann.info";
      dns = rec {
        base_domain = "tailnet.honermann.info";
        search_domains = [
          base_domain
          "localdomain"
        ];
        nameservers.global = [
          "100.64.0.5"
        ];
      };
      policy.path = ./headscale_acl.hujson;
    };
  };
  environment.persistence."/permament".directories = [
    "/var/lib/headscale"
  ];
}
