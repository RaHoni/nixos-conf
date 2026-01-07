{ lib, config, ... }:
let
  pihole = config.local.ips."pi.hole";
in
{
  imports = [
    ../generic/tailscale.nix
    ../generic/sops.nix
    ../generic/ips.nix
  ];
  local.tailscale = {
    enable = true;
    exit-node = true;
  };

  services.tailscale.extraSetFlags = [
    "--advertise-routes=${pihole.ipv4.address}/32,${pihole.ipv6.address}/128"
  ];

  networking = {
    useDHCP = lib.mkForce true;
    hostName = "tailscale-exit";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  system.stateVersion = "25.11";
}
