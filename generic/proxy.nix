{ config, lib, ... }:
let
  subnet = "192.168.3.";

  proxyHost = {address, proxyWebsockets ? false, extraConfig ? "", serverAliases ? []}: {
    inherit serverAliases extraConfig;
    enableACME = true;
    forceSSL = true;
    http2 = true;
    locations."/" = {
      proxyPass = address;
      inherit proxyWebsockets;
    };
  };
in
{
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

    virtualHosts = {
      "binarycache.honermann.info" = proxyHost { address = "http://192.168.2.20:5000"; };

      "calibre.honermann.info" = proxyHost {
        address = "http://${subnet}103:8080";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 100M;";
      };

      "home.honermann.info" = proxyHost {
        address = "http://${subnet}211:8123";
        proxyWebsockets = true;
      };

      "hoerbuecher.honermann.info" = proxyHost {
        address = "http://${subnet}209:8000";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 8G;";
      };

      "hydra.honermann.info" = proxyHost { address = "http://192.168.2.20:300"; };

      "nextcloud.honermann.info" = proxyHost {
        serverAliases = [ "honermann.info" ];
        address = "http://${subnet}210";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 8G;";
      };

      "server.honermann.info" = proxyHost { address = "https://${subnet}1:8006"; };
    };
  };
  security.acme.certs."nextcloud.honermann.info".extraDomainNames = [ "honermann.info" ];
}
