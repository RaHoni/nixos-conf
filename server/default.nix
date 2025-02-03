{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  ips = config.local.ips;
  defaultPrefix = 23;
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

  systemd.timers.podman-auto-update.enable = true;

  boot.supportedFilesystems = [
    "zfs"
    "lvm"
  ];

  boot.zfs.package = pkgs.zfs_2_3;

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
      "/var/lib/private/factorio"
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
      "/root/.local/share/nix/trusted-settings.json"
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

  myModules.autoUpgrade.enable = true;

  networking = {
    dhcpcd.IPv6rs = true;
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
        macAddress = "86:2E:6C:D4:F6:1E";
        useDHCP = true;
        tempAddress = "disabled";
        ipv4.addresses = [
          {
            address = ips.server.ipv4;
            prefixLength = defaultPrefix;
          }
          {
            address = ips."pi.hole".ipv4;
            prefixLength = defaultPrefix;
          }
          {
            address = ips.audiobookshelf.ipv4;
            prefixLength = defaultPrefix;
          }
          {
            address = ips.nebula-lighthouse.ipv4;
            prefixLength = defaultPrefix;
          }
          {
            address = ips.ssl-proxy.ipv4;
            prefixLength = defaultPrefix;
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
