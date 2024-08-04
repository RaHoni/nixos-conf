{ pkgs, config, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
    };
    tmp.useTmpfs = true;
    initrd = {
      systemd.enable = true;
      luks.devices."crypted".crypttabExtraOpts = ["fido2-device=auto"];  # cryptenroll
    };
  };


  environment.etc = {
    "libinput/local-overrides.quirks".text = ''
      [Keyboard]
      MatchUdevType=keyboard
      MatchName=Framework Laptop 16 Keyboard Module - ANSI Keyboard
      AttrKeyboardIntegration=internal
    '';
  };

  environment.systemPackages = with pkgs; [
    mprisRecord
    filelight
    firefox
    git
    gnupg
    kate
    libreoffice
    miraclecast
    nmap
    qpwgraph
    signal-desktop
    vlc
    zsh-completions
  ];

  hardware.bluetooth.enable = true;

  networking = {
    hostName = "raoul-framework";
    networkmanager.enable = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  programs = {
    adb.enable = true;
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };
    kdeconnect.enable = true;
    neovim.defaultEditor = true;
    nix-ld.enable = true;
    noisetorch.enable = true;
    partition-manager.enable = true;
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    polkit-1.u2fAuth = true;
  };

  services = {
    fwupd.enable = true;
    gvfs.enable = true; #Allow programs to directly acces remote shares
    pcscd.enable = true; # yubikey ccid
    teamviewer.enable = true;
    xserver.enable = true; #Used by sddm
  };

  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://nextcloud.honermann.info/s/G4ism5PGRjApS97/download/Hintergrund.jpg";
      sha256 = "cff23312a75d25c0e3a7387c1c74658ba84ec1f8aa13f1a7ac96ff4bbfbb2169";
    };
    override = {
      base01 = "#313727";
    };
    polarity = "dark";
    fonts = {
      serif = config.stylix.fonts.sansSerif;
      monospace = {
        package = pkgs.nerdfonts;
        name = "DejaVuSansM Nerd Font Mono";
      };
      sizes = {
        applications = 13;
        desktop = 12;
        popups = 14;
      };
    };
    opacity = {
      desktop = 0.6;
      popups = 0.6;
    };
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 24;
    };
  };
  users = {
    groups.raoul.gid = 1000;
    users.raoul = {
      uid = 1000;
      isNormalUser = true;
      description = "Raoul Honermann";
      hashedPassword = "$y$j9T$2qmWuo6/DJXoG.45LLjDX/$Y/NnNHfsQXULwubyI1lPavjfe3fYv/KTWMR4aPLhsSB";
      extraGroups = [ "networkmanager" "wheel" "i2c" "render" "raoul" "dialout" "adbusers" "video" ];
      openssh.authorizedKeys.keyFiles = [
        ../generic/sshPubkeys/Surface_id_ed25519.pub
      ];
      packages = with pkgs; [
        discord
        gh
        jameica
        keepassxc
        kleopatra
        nebula
        nixpkgs-fmt
        prismlauncher #Minecraft
        sops
        spotify
        tetex #full latex
        whatsapp-for-linux
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
