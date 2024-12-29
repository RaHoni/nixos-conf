{ config, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.local.ips = mkOption {
    type = types.attrsOf (
      types.submodule ({
        options = {
          ipv4 = mkOption {
            type = types.str;
            description = "IPv4 address for the server.";
          };
          ipv6 = mkOption {
            type = types.str;
            description = "IPv6 address for the server.";
          };
          bacula = mkOption {
            type = types.submodule ({
              options = {
                ipv4 = mkOption {
                  type = types.str;
                  description = "IPv4 address for Bacula.";
                };
                ipv6 = mkOption {
                  type = types.str;
                  description = "IPv6 address for Bacula.";
                };
              };
            });
            description = "Bacula-specific IP configuration.";
          };
        };
      })
    );
    description = "Configuration for local IPs, including server and Bacula settings.";
  };

  config = {
    local.ips = rec {
      server = {
        ipv4 = "192.168.3.1";
        ipv6 = "fd00::4:1";
        bacula = {
          inherit (server) ipv4 ipv6;
        };
      };
      "pi.hole" = {
        ipv4 = "192.168.3.102";
        ipv6 = "fd00::4:102";
      };
      nebula-lighthouse = {
        ipv4 = "192.168.3.208";
        ipv6 = "fd00::4:208";
      };
      audiobookshelf = {
        ipv4 = "192.168.3.209";
        ipv6 = "fd00::4:209";
      };
      binarycache = {
        ipv4 = "192.168.2.40";
        ipv6 = "fe80::fb19:47d3:6a1b:d1f";
      };
      hydra = {
        inherit (binarycache) ipv4 ipv6;
      };
    };
  };
}
