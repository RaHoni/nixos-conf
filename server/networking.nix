{ config, ... }:
let
  ips = config.myModules.ips;
in
{
  networking = {
    dhcpcd.IPv6rs = true;
    useDHCP = false;
    hostName = "server";
    hostId = "abb92398";
    useNetworkd = false;
    nameservers = [
      "192.168.1.1"
      "1.1.1.1"
    ];
    bridges = {
      br0 = {
        interfaces = [ "eth0" ];
      };
    };
    nat = {
      enable = true;
      internalInterfaces = [
        "ve-+"
        "veth0"
      ];
      externalInterface = "eth0";
      enableIPv6 = true;
    };
    interfaces = {
      br0 = {
        macAddress = "86:2E:6C:D4:F6:1E";
        useDHCP = true;
        tempAddress = "disabled";
        ipv4.addresses = [
          {
            address = "192.168.1.14";
            prefixLength = 24;
          }
          ips.server.ipv4
          ips.audiobookshelf.ipv4
        ];
        ipv6.addresses = [
          ips.server.ipv6
          ips."pi.hole".ipv6
          ips.audiobookshelf.ipv6
        ];
      };
    };
  };
}
