{ config, lib, ... }:
let
  ips = config.local.ips;
in
{
  imports = [
    ./hardware-config.nix
    ../generic/ips.nix
  ];
  sops.age.keyFile = lib.mkForce "/permament/sops-nix/key.txt";

  boot.supportedFilesystems = [
    "zfs"
    "lvm"
  ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=3G"
      "mode=755"
    ]; # mode=755 so only root can write to those files
  };

  boot.zfs.extraPools = [ "MainZFS" ];

  networking = {
    hostName = "server";
    hostId = "abb92398";
    useNetworkd = false;
    nameservers = [
      ips."pi.hole".ipv4
      ips."pi.hole".ipv6
      "192.168.2.1"
      "1.1.1.1"
    ];
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = ips.server.ipv4;
            prefixLength = 23;
          }
          {
            address = ips.audiobookshelf.ipv4;
            prefixLength = 23;
          }
          {
            address = ips.nebula-lighthouse.ipv4;
            prefixLength = 23;
          }
          {
            address = "192.168.3.207";
            prefixLength = 23;
          }
        ];
        ipv6.addresses = [
          {
            address = ips.server.ipv6;
            prefixLength = 48;
          }
          {
            address = ips.audiobookshelf.ipv6;
            prefixLength = 48;
          }
          {
            address = ips.nebula-lighthouse.ipv6;
            prefixLength = 48;
          }
        ];
      };
    };
    defaultGateway = {
      address = "192.168.2.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "fd00::e228:6dff:fe3f:ccc9";
      interface = "eth0";
    };
  };
  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../generic/sshPubkeys/id_ecdsa_proxmox.pub ];

}
