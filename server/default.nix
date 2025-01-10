{
  config,
  lib,
  inputs,
  ...
}:
let
  ips = config.local.ips;
in
{
  imports = [
    ./hardware-config.nix
    ../generic/ips.nix
    ../generic/networking.nix
  ];
  sops.age.keyFile = lib.mkForce "/permament/sops-nix/key.txt";
  sops.secrets."wireguard/wireguard-priv-key" = {
    key = "wireguard-priv-key";
    sopsFile = ../secrets/server/wireguard.yaml;
  };

  boot.supportedFilesystems = [
    "zfs"
    "lvm"
  ];

  containers = {
    proxy = {
      autoStart = true;
      config = (import ../proxy/default.nix);
      bindMounts."/var/lib/acme".isReadOnly = false;
    };
    mailserver = {
      autoStart = true;
      config = (import ./mailserver.nix);
      specialArgs = {
        sms = inputs.simple-mail-server.nixosModules.mailserver;
      };
      bindMounts."/var/lib/acme" = {
        hostPath = "/var/lib/acme/mail";
        isReadOnly = false;
      };
      bindMounts."/wireguard".hostPath = "/run/secrets/wireguard";
      privateNetwork = true;
      hostAddress = "169.254.26.129";
      localAddress = "169.254.26.130";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      enableTun = true;
    };
  };

  environment.persistence."/permament" = {
    hideMounts = true;
    directories = [
      "/etc/nixos/"
      "/var/pihole" # This is a Volume for te pihole container so that we can set the adlists
      "/var/lib/nixos/"
      "/var/lib/containers"
      "/var/lib/factorio"
      "/var/lib/nixos-containers/mailserver"
      {
        directory = "/var/lib/audiobookshelf";
        user = "audiobookshelf";
        group = "audiobookshelf";
      }
      {
        directory = "/var/lib/mysql";
        user = "mysql";
        group = "mysql";
      }
      {
        directory = "/var/lib/acme";
        user = "acme";
        group = "acme";
      }
    ];
    files = [
      "/root/.zsh_history"
      "/root/.ssh/known_hosts"
    ];
  };

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
      eth0 = {
        ipv4.addresses = [
          {
            address = ips.server.ipv4;
            prefixLength = 23;
          }
          {
            address = ips."pi.hole".ipv4;
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
            address = ips."pi.hole".ipv6;
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
      br0.useDHCP = true;
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
