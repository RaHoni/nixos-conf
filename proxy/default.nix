{ lib, ... }:
{
  networking.hostName = "ssl-proxy";
  networking.firewall.enable = lib.mkForce false;
  system.stateVersion = "23.11";
}
