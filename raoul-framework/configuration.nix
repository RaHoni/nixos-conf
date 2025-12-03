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
      luks.devices."crypted".crypttabExtraOpts = [ "fido2-device=auto" ]; # cryptenroll
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  local.tailscale.enable = true;

  environment.etc = {
    "libinput/local-overrides.quirks".text = ''
      [Keyboard]
      MatchUdevType=keyboard
      MatchName=Framework Laptop 16 Keyboard Module - ANSI Keyboard
      AttrKeyboardIntegration=internal
    '';
  };

  environment.systemPackages = with pkgs; [
    bacula
    ffmpeg
    firefox
    fw-ectool
    git
    gnupg
    kdePackages.filelight
    kdePackages.kate
    keepassxc-autotype
    libimobiledevice
    libreoffice
    miraclecast
    nmap
    platformio
    qpwgraph
    signal-desktop
    tailscale-systray
    vdhcoapp
    vlc
    xournalpp
    zsh-completions
  ];

  hardware.bluetooth.enable = true;

  myModules.autoUpgrade = {
    enable = true;
    delayForInternet = true;
  };

  networking = {
    hostName = "raoul-framework";
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [
      67 # DHCP For Hotspots
      34197 # Factorio Gameserver
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  programs = {
    adb.enable = true;
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };
    kdeconnect.enable = true;
    neovim.defaultEditor = true;
    nix-ld = {
      enable = true;
      libraries =
        with pkgs;
        [
          acl
          attr
          bzip2
          dbus
          expat
          fontconfig
          freetype
          fuse3
          icu
          libnotify
          libsodium
          libssh
          libunwind
          libusb1
          libuuid
          nspr
          nss
          stdenv.cc.cc
          util-linux
          zlib
          zstd
        ]
        ++ lib.optionals (config.hardware.graphics.enable) [
          pipewire
          cups
          libxkbcommon
          pango
          mesa
          libdrm
          libglvnd
          libpulseaudio
          atk
          cairo
          alsa-lib
          at-spi2-atk
          at-spi2-core
          gdk-pixbuf
          glib
          gtk3
          libGL
          libappindicator-gtk3
          vulkan-loader
          xorg.libX11
          xorg.libXScrnSaver
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxcb
          xorg.libxkbfile
          xorg.libxshmfence
        ];
    };
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
    fwupd.package = pkgs.unstable.fwupd;
    gvfs.enable = true; # Allow programs to directly acces remote shares
    pcscd.enable = true; # yubikey ccid
    teamviewer.enable = true;
    usbmuxd.enable = true;
    xserver.enable = true; # Used by sddm
  };

  stylix = {
    enable = true;
    image = ./backround-image.png;
    base16Scheme = ./palette.yaml;
    polarity = "dark";
    fonts = {
      serif = config.stylix.fonts.sansSerif;
      monospace = {
        package = pkgs.nerd-fonts.dejavu-sans-mono;
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
      extraGroups = [
        "adbusers"
        "dialout"
        "i2c"
        "ld"
        "networkmanager"
        "raoul"
        "render"
        "scanner"
        "video"
        "wheel"
        config.users.groups.keys.name
        config.users.groups.vboxusers.name
      ];
      openssh.authorizedKeys.keyFiles = [
        ../generic/sshPubkeys/Surface_id_ed25519.pub
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDu1IkXlR2SVaSH2kkAl8kafEmngmTXaDna2/rEw/njnR/xYNanWGUO91cf2gy4WHGM9ZH39P3XYGQErOHkQkZK/x9pkrAoybsYKpzQaLagMMmZCYd7wqeFB7HFmFwirc9/NpN524KCw1oiNqbBOTqFi3pQPyFxF63AHjwydGg4I0Sezd1szvuAU7fHRmLQF5hqGzX0C/GG9bJRF5kWKctv72rcEKkyxKRRhCzGi8ciupNXX/oITRkzWlwYYNVshn2eW28DE3vmLCh3krlEqq2pMmAICV+3Wm2baR01LLzBYWfydEqkxsh2xyQV7ODx954H20gIuVqyP1TVLi9f99bJgnPCOUUbuCB/ARBuDqsPPgZRhGX5k0xNPPAbEreqHazc1zl6llgMnLwg5C6coluRybMsaUE9hc+8uczic9NWfCJITXKuKobPN5UKlHyJfHiLcmtiGDOi75CXv7neVhBH/e99LtooqrCqsmTf63Q9dscfHWffp2YFqN6+iWN39Uk5T2gV/+U1fdUP7xs2hvff7eRAAZOdSng5/a6jkGN2uGRphBeqBzl6pEG7st6JOIMq6fL7BK0pKjKAzK7yTkEjSKPAGd7q8SD7IMJLjIDMjWlxkfgcOSFy2TNAOghy4Q+SilP3PrCf5Wyh8ykwMD9hhOvLyIaJBGqlVDolq2EMgw== generated by Keepass2Android"
      ];
      packages = with pkgs; [
        discord
        gh
        jameica
        kdePackages.kleopatra
        kanidm_1_7
        libation # Audible downloader
        nebula
        nixpkgs-fmt
        prismlauncher # Minecraft
        sops
        spotify
        texliveFull # full latex
        omnissa-horizon-client # FH VDI
        wasistlos
        yubioath-flutter
      ];
    };
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
