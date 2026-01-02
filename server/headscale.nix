{ config, ... }:
{
  sops.secrets.headscale = {
    sopsFile = ../secrets/headscale.yaml;
    owner = "headscale";
  };
  services.headscale = {
    enable = true;
    port = 443;
    address = "[::]";
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
          "localdomain"
        ];
      };
      policy.path = ./headscale_acl.hujson;
      tls_letsencrypt_hostname = "headscale.honermann.info";
    };
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
