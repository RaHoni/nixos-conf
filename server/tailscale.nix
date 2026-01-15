{ lib, config, ... }:
let
  pihole = config.local.ips."pi.hole";
  tailscale-exit = config.local.ips.tailscale-exit;
in
{
  imports = [
    ../generic/modules
    ../generic/sops.nix
  ];
  local.tailscale = {
    enable = true;
    exit-node = true;
    routes = [
      "${pihole.ipv4.address}/32"
      "${pihole.ipv6.address}/128"
      "192.168.1.251/32"
    ];
  };

  services.tailscale = {
    extraUpFlags = [
      "--snat-subnet-routes=false"
    ];
  };

  networking = {
    hostName = "tailscale-exit";
    enableIPv6 = true;
    useHostResolvConf = false;
    tempAddresses = "disabled";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    defaultGateway.address = config.local.ips.gateway.ipv4.address;
    interfaces.eth0 = {
      ipv4.addresses = [ tailscale-exit.ipv4 ];
      ipv6.addresses = [ tailscale-exit.ipv6 ];
    };
    firewall = {
      allowPing = true;
    };
  };
  system.stateVersion = "25.11";
}
