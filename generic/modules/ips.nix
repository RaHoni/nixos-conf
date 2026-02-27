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
  options.myModules.ips = mkOption {
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
        };
      })
    );
    description = "Configuration for local IPs, including server and Bacula settings.";
  };

  config = {
    myModules.ips = rec {
      cloudflare = {
        ipv4.address = "1.1.1.1";
        ipv6.address = "2606:4700:4700::1001";
      };
      gateway.ipv4.address = "192.168.1.1";
      server = {
        ipv4.address = "192.168.1.200";
        ipv6.address = "fd00::4:1";
      };
      "pi.hole" = {
        ipv4.address = "192.168.1.252";
        ipv6.address = "fd00::4:102";
      };
      audiobookshelf = server;
      binarycache = {
        ipv4.address = "192.168.1.200";
        ipv6.address = "fe80::946e:8793:2804:17e9";
      };
      pikaraoke.ipv4.address = "192.168.1.210";
      home-assistant.ipv4.address = "192.168.1.38";
      hydra = {
        inherit (binarycache) ipv4 ipv6;
      };
      ssl-proxy = {
        ipv4.address = "192.168.1.207";
      };
      tailscale-exit = {
        ipv4.address = "192.168.1.229";
        ipv6.address = "fd00::5:1";
      };
      kanidm = {
        ipv4.address = "192.168.1.201";
      };
      music = {
        ipv4.address = "192.168.1.202";
      };
      vps = {
        ipv4 = {
          address = "212.227.135.200";
          prefixLength = "32";
        };
        ipv6 = {
          address = "2a01:239:2b9:9600::1";
          prefixLength = 128;
        };
      };
    };
  };
}
