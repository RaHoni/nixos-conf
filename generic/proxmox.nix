{ config, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  proxmoxLXC.manageNetwork = true;
  networking = {
    useDHCP = false;
    useHostResolvConf = false;
    useNetworkd = true;
  };
  networking.firewall.allowPing = true;


  system.autoUpgrade = {
    flake = "github:RaHoni/nixos-conf";
    enable = true;
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
    randomizedDelaySec = "30min";
  };

  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [ 22 ];
  };
}
