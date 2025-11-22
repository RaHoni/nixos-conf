{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  ips = config.local.ips;
  defaultPrefix = 24;
in
{
  imports = [
    ./hardware-config.nix
    ../generic/ips.nix
    ../generic/networking.nix
  ];
  sops.age.keyFile = lib.mkForce "/permament/sops-nix/key.txt";
  sops.secrets = {
    "wireguard/wireguard-priv-key" = {
      key = "wireguard-priv-key";
      sopsFile = ../secrets/server/wireguard.yaml;
    };
    cloudflare-api-key.sopsFile = ../secrets/server/ddns.yaml;
  };

  systemd.timers.podman-auto-update.enable = true;

  services.avahi.enable = true;

  console.keyMap = "de";

  boot.supportedFilesystems = [
    "zfs"
    "lvm"
  ];

  boot.tmp.cleanOnBoot = true;

  boot.zfs.package = pkgs.zfs_2_3;

  systemd.services = {
    "container@kanidm" = rec {
      wants = [
        "container@proxy.service"
      ];
      after = wants;
    };
    "container@mailserver" = rec {
      wants = [
        "container@proxy.service"
        "container@kanidm.service"
      ];
      after = wants;
    };
  };

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
      bindMounts."/var/lib/acme/mail.honermann.info" = {
      };
      bindMounts."/wireguard".hostPath = "/run/secrets/wireguard";
      privateNetwork = true;
      hostAddress = "169.254.26.129";
      localAddress = "169.254.26.130";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      enableTun = true;
      timeoutStartSec = "4min";
    };
    kanidm = {
      autoStart = true;
      config = (import ./kanidm.nix);
      hostAddress = "169.253.26.100";
      localAddress = "169.253.26.1";
      specialArgs = {
        sops = inputs.sops-nix.nixosModules.sops;
      };
      privateNetwork = true;
      bindMounts."/var/lib/acme/account.honermann.info" = { };
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/private/ 0700" ];

  environment.persistence."/permament" = {
    hideMounts = true;
    directories = [
      "/backmeup"
      "/etc/nixos/"
      "/var/pihole" # This is a Volume for te pihole container so that we can set the adlists
      "/var/lib/nixos/"
      "/var/lib/nebula/"
      "/var/lib/containers"
      "/var/lib/private" # because of too much errors
      {
        directory = "/var/lib/private/factorio";
        user = "factorio";
        group = "factorio";
      }
      "/var/lib/nixos-containers/mailserver"
      "/var/lib/nixos-containers/kanidm"
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
  services.zfs.autoScrub.enable = true;

  services.cloudflare-dyndns = {
    enable = true;
    ipv4 = false;
    ipv6 = true;
    domains = [ "honermann.info" ];
    apiTokenFile = config.sops.secrets.cloudflare-api-key.path;
  };

  myModules.autoUpgrade.enable = true;
  myModules.autoUpgrade.allowReboot = true;

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
            address = "192.168.1.14";
            prefixLength = 24;
          }

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
  };
  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  users.users.root = {
    openssh.authorizedKeys = {
      keyFiles = [ ../generic/sshPubkeys/id_ecdsa_proxmox.pub ];
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwmfcED8/DU0g9LdU3r2+KR6TbfzixXKH7tM7keNwd1rEzq2SX8EbU9sD089C6mPrmoLPVtcWeraKWaEn5vTJ2mUXUpYw2u71V0qIr0q43DB2r9fxCoykuijT+r2HrrDhrnr4C1nezvFWncdYxJPXPPROTGiWpyDqd3/BA60/Ho5ag8YnfeIkpI+I6YadbRFggYnJhE7sIbljHtlMAextHZZMy9q/B0/Fmd9VAOhZrFH2SgO7IHI1owuc28d/ISivZBZw0SmjFC+YlksbJG+0QCwB2zk3IOOb2QF8VOSsbY9GFmUOwnSiU1dZdm2f0pZ46IqcRWoDSvOJZV+ilsjjkFFbIiXBBHOLifbZ0cPWpvTozUtdHLbODwc9U4UuqdFEaUeUs/XqMp1pecx3BMHtwUZ2ssjqjlnhv4SN/bLQfanM7E74BJgnVC9n66sEdWDGFcSBCLjTiUd5tKcb0xumAY7I3BtK1vUBhZvLK2S2yBhzUtTNGZDRbwfFOzjbj8G8= Kodi"
      ];
    };
    hashedPassword = "$y$j9T$0Th6cYXM36/0IxGbj.hm7.$vErijiMepuPpDq.vVBspXefNq/U/ccQx50V3Eo6BDc2";
    packages = with pkgs; [
      ffmpeg-vpl.ffmpeg-qsv
    ];
  };

}
