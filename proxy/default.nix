{ lib, ... }:
{
  networking.hostName = "ssl-proxy";
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.sshd.enable = true;
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  #networking.firewall.enable = lib.mkForce false;
  system.stateVersion = "23.11";
}
