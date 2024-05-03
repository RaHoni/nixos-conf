{ config, lib, ... }:
let
  subnet = "192.168.3.";
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
      #messdiener proxy
      "messdiener.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations = {
          "/".proxyPass = "https://${subnet}203";
          "/.well-known/carddav".proxyPass = "http://${subnet}200/dav.php";
          "/.well-known/caldav".proxyPass = "http://${subnet}200/dav.php";
        };
      };

      "nextcloud.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/" = {
          proxyPass = "http://${subnet}210";
          proxyWebsockets = true;
        };
        extraConfig = "client_max_body_size 8G;";
      };

      "calibre.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/" = {
          proxyPass = "http://${subnet}103:8080";
          proxyWebsockets = true;
        };
      };

      "hoerbuecher.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/" = {
          proxyPass = "http://${subnet}209:8000";
          proxyWebsockets = true;
        };
        extraConfig = "client_max_body_size 8G;";
      };

      "packete.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/".proxyPass = "http://${subnet}205";
      };

      "baikal.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations = {
          "/" = {
            proxyPass = "https://${subnet}200";
            proxyWebsockets = true;
          };
        };
      };

      "webdav.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/".proxyPass = "https://${subnet}204";
      };

      "server.honermann.info" = {
        enableACME = true;
        forceSSL = true;
        http2 = true;
        locations."/".proxyPass = "https://${subnet}1:8006";
      };

      "honermann.info" = {
        locations = {
          "/.well-known/carddav".proxyPass = "http://${subnet}200/dav.php";
          "/.well-known/caldav".proxyPass = "http://${subnet}200/dav.php";
        };
      };
    };
  };
}
