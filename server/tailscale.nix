{ lib, ... }:
{
  imports = [
    ../generic/tailscale.nix
    ../generic/sops.nix
  ];
  local.tailscale = {
    enable = true;
    exit-node = true;
  };

  networking = {
    useDHCP = lib.mkForce true;
    hostName = "tailscale-exit";
  };
  system.stateVersion = "25.11";
}
