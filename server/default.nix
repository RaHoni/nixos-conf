{
  config,
  lib,
  inputs,
  pkgs,
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
    ./networking.nix
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

  # critical fix for mullvad-daemon to run in container, otherwise errors with: "EPERM: Operation not permitted"
  # It seems net_cls API filesystem is deprecated as it's part of cgroup v1. So it's not available by default on hosts using cgroup v2.
  # https://github.com/mullvad/mullvadvpn-app/issues/5408#issuecomment-1805189128
  fileSystems."/tmp/net_cls" = {
    device = "net_cls";
    fsType = "cgroup";
    options = [ "net_cls" ];
  };

  containers = {
    proxy = {
      autoStart = true;
      config = (import ../proxy/default.nix);
      bindMounts = {
        "/var/lib/acme" = { };
        "${config.sops.secrets.cloudflare-api-key.path}" = { };
      };
      specialArgs = {
        cloudflare-api-key = config.sops.secrets.cloudflare-api-key.path;
      };
      privateNetwork = true;
      hostBridge = "br0";
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
      hostBridge = "br0";
      enableTun = true;
      timeoutStartSec = "4min";
    };
    music = {
      autoStart = true;
      config = (import ./music.nix);
      bindMounts = {
        "/var/lib/private/snapserver".isReadOnly = false;
        "/var/lib/private/music-assistant".isReadOnly = false;
      };
      privateNetwork = true;
      hostBridge = "br0";
    };
    kanidm = {
      autoStart = true;
      config = (import ./kanidm.nix);
      hostBridge = "br0";
      specialArgs = {
        sops = inputs.sops-nix.nixosModules.sops;
      };
      privateNetwork = true;
      bindMounts."/var/lib/acme/account.honermann.info" = { };
    };
    tailscale-exit = {
      autoStart = true;
      config = (import ./tailscale.nix);
      hostBridge = "br0";
      enableTun = true;
      specialArgs = {
        sops = inputs.sops-nix.nixosModules.sops;
      };
      privateNetwork = true;
      bindMounts."/var/lib/tailscale/" = {
        isReadOnly = false;
        hostPath = "/var/lib/tailscale-exit-node";
      };
    };
    torrent = {
      autoStart = true;
      config = (import ../private/seerr.nix);
      enableTun = true;
      hostBridge = "br0";
      specialArgs = {
        sops = inputs.sops-nix.nixosModules.sops;
      };
      privateNetwork = true;
      bindMounts = {
        "/var/Filme".isReadOnly = false;
        "/var/Serien".isReadOnly = false;
        "/var/nginx".isReadOnly = false;
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/private/ 0700" ];

  environment.persistence."/permament" = {
    hideMounts = true;
    directories = [
      "/backmeup"
      "/etc/nixos/"
      "/var/lib/containers"
      "/var/lib/nixos-containers/kanidm"
      "/var/lib/nixos-containers/mailserver"
      "/var/lib/nixos-containers/torrent"
      "/var/lib/nixos/"
      "/var/lib/private" # because of too much errors
      "/var/pihole" # This is a Volume for the pihole container so that we can set the adlists
      "/var/lib/tailscale/"
      "/var/lib/tailscale-exit-node"
      {
        directory = "/var/lib/private/factorio";
        user = "factorio";
        group = "factorio";
      }
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
      {
        directory = "/var/nginx";
        mode = "0777";
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

  myModules.autoUpgrade.enable = true;
  myModules.autoUpgrade.allowReboot = true;
  local.tailscale = {
    enable = true;
    server = true;
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
