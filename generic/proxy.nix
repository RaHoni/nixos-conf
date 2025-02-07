{ config, lib, ... }:
let
  subnet = "192.168.3.";

  ips = config.local.ips;

  proxyHost =
    {
      address,
      proxyWebsockets ? false,
      extraConfig ? "",
      serverAliases ? [ ],
    }:
    {
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

    virtualHosts = {
      "binarycache.honermann.info" = proxyHost { address = "http://${ips.binarycache.ipv4}:5000"; };

      "home.honermann.info" = proxyHost {
        address = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };

      "hoerbuecher.honermann.info" = proxyHost {
        address = "http://${ips.audiobookshelf.ipv4}:8000";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 8G;";
      };

      "hydra.honermann.info" = proxyHost { address = "http://${ips.hydra.ipv4}:3000"; };

      "honermann.info" = proxyHost {
        serverAliases = [ "nextcloud.honermann.info" ];
        address = "http://${ips.server.ipv4}";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 10G;";
      };

      "karaoke.honermann.info" = proxyHost {
        address = "http://10.88.0.5:5555";
      };

      "media.honermann.info" = proxyHost {
        address = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = "proxy_buffering off;"; # Disable buffering when the nginx proxy gets very resource heavy upon streaming
      };
    };
  };
}
