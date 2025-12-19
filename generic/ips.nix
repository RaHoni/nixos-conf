{ config, lib, ... }:
let
  inherit (lib) types mkOption;
  inherit (types) submodule;
  addrOpts =
    v:
    assert v == 4 || v == 6;
    {
      options = {
        address = mkOption {
          type = types.str;
          description = ''
            IPv${toString v} address of the interface. Leave empty to configure the
            interface using DHCP.
          '';
        };

        prefixLength = mkOption {
          type = types.ints.between 0 (if v == 4 then 32 else 128);
          description = ''
            Subnet mask of the interface, specified as the number of
            bits in the prefix (`${if v == 4 then "24" else "64"}`).
          '';
          default = if v == 4 then 24 else 48;
        };
      };
    };
in
{
  options.local.ips = mkOption {
    type = types.attrsOf (
      types.submodule ({
        options = {
          ipv4 = mkOption {
            type = submodule (addrOpts 4);
            description = "IPv4 address for the server.";
          };
          ipv6 = mkOption {
            type = submodule (addrOpts 6);
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
        ipv4.address = "192.168.1.200";
        ipv6.address = "fd00::4:1";
        bacula = {
          ipv4 = server.ipv4.address;
          ipv6 = server.ipv6.address;
        };
      };
      "pi.hole" = {
        ipv4.address = "192.168.1.252";
        ipv6.address = "fd00::4:102";
      };
      nebula-lighthouse = {
        ipv4.address = "192.168.1.208";
        ipv6.address = "fd00::4:208";
      };
      audiobookshelf = {
        ipv4.address = "192.168.1.209";
        ipv6.address = "fd00::4:209";
      };
      binarycache = {
        ipv4.address = "192.168.1.200";
        ipv6.address = "fe80::946e:8793:2804:17e9";
      };
      hydra = {
        inherit (binarycache) ipv4 ipv6;
      };
      ssl-proxy = {
        ipv4.address = "192.168.1.207";
      };
    };
  };
}
