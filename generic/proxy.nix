{ config, lib, ... }:
let
  subnet = "192.168.3.";

  ips = config.local.ips;

  proxyHost =
    name:
    {
      address,
      proxyWebsockets ? false,
      extraConfig ? "",
      serverAliases ? [ ],
    }:
    let
      acmePath = "/var/lib/acme/${name}";
    in
    {
      inherit serverAliases extraConfig;
      sslCertificate = "${acmePath}/fullchain.pem";
      sslCertificateKey = "${acmePath}/key.pem";
      sslTrustedCertificate = "${acmePath}/chain.pem";
      forceSSL = true;
      http2 = true;
      locations."/" = {
        proxyPass = address;
        inherit proxyWebsockets;
      };
    };
  inherit (lib) mapAttrs;
in
{
  imports = [ ./ips.nix ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "webmaster@honermann.info";
  };

  #reverse proxy
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    #hardened security settings
    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    #enable HSTS and other hardening (see nixos wiki)
    appendHttpConfig = ''
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      more_set_headers 'Strict-Transport-Security: $hsts_header';
      more_set_headers 'Referrer-Policy: strict-origin-when-cross-origin';
      more_set_headers 'X-Frame-Options: SAMEORIGIN';
      more_set_headers 'X-Content-Type-Options: nosniff';
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';

    virtualHosts = mapAttrs proxyHost {
      "account.honermann.info" = {
        address = "https://${ips.kanidm.ipv4.address}";
      };

      "binarycache.honermann.info" = {
        address = "http://${ips.binarycache.ipv4.address}:5000";
      };

      "headscale.honermann.info" = {
        address = "http://192.168.1.14:8081";
        proxyWebsockets = true;
      };

      "home.honermann.info" = {
        address = "http://192.168.1.14:8123";
        proxyWebsockets = true;
      };

      "hoerbuecher.honermann.info" = {
        address = "http://${ips.audiobookshelf.ipv4.address}:8000";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 8G;";
      };

      "hydra.honermann.info" = {
        address = "http://${ips.hydra.ipv4.address}:3000";
      };

      "honermann.info" = {
        serverAliases = [ "nextcloud.honermann.info" ];
        address = "http://${ips.server.ipv4.address}";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 10G;";
      };

      "karaoke.honermann.info" = {
        address = "http://${ips.pikaraoke.ipv4.address}:5555";
      };

      "media.honermann.info" = {
        address = "http://192.168.1.14:8096";
        proxyWebsockets = true;
        extraConfig = "proxy_buffering off;"; # Disable buffering when the nginx proxy gets very resource heavy upon streaming
      };
      "anfragen.honermann.info" = {
        address = "http://192.168.1.14:5055";
      };
    };
  };
}
