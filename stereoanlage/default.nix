{ pkgs, config, ... }:
{

  boot = {
    kernelParams = [ "cma=256M" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  hardware.pulseaudio.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapDevices";
      size = 1024;
    }
  ];

  # WiFi
  hardware = {
    firmware = [ pkgs.wireless-regdb ];
    enableAllFirmware = true;
  };

  networking = {
    hostName = "stereoanlage";
    firewall.allowedTCPPorts = [
      10700
    ];
    wireless.enable = true;
  };

  systemd.user.services.snap-client = {
    wantedBy = [
      "pulseaudio.service"
    ];
    after = [
      "pulseaudio.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.1.200";
    };
  };

  users.users = rec {
    root.openssh.authorizedKeys.keyFiles = [ ../generic/sshPubkeys/id_ed25519_kodi.pub ];
    anlage = {
      openssh.authorizedKeys.keyFiles = root.openssh.authorizedKeys.keyFiles;
      password = "test";
      extraGroups = [ "wheel" ];
    };
  };

  services = {
    openssh.enable = true;
    wyoming = rec {
      satellite = {
        enable = true;
        area = "Wohnzimmer";
        user = "anlage";
        vad.enable = false;
        extraArgs = [
          "--wake-uri"
          openwakeword.uri
          "--wake-word-name"
          "hey_jarvis"
        ];
        sounds = {
          awake = ../generic/sounds/voice_assistant_start.wav;
          done = ../generic/sounds/voice_assistant_stop.wav;
        };
      };
      openwakeword = {
        enable = true;
        uri = "unix://tmp/wake.socket";
        preloadModels = [
          "hey_jarvis"
          "ok_nabu"
        ];
      };
    };
  };

  system.stateVersion = "25.05";
}
