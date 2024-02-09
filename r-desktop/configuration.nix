{ pkgs, lib, nixpkgs-ffmpeg, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./users.nix
  ];

  environment.sessionVariables = {
    INTEL_MEDIA_RUNTIME = "ONEVPL";
    LIBVA_DRIVER_NAME = "iHD";
    ONEVPL_SEARCH_PATH = lib.strings.makeLibraryPath (with pkgs.ffmpeg-vpl; [ oneVPL-intel-gpu ]);
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "r-desktop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.eth0.wakeOnLan.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };
  services.gvfs.enable = true;
  programs.adb.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Needed for yubikey ccid Functionality
  services.pcscd.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    kate
    libreoffice
    jdk
    android-tools
    python3
    signal-desktop
    zsh-completions
    git
    nmap
    gnupg
    filelight
    vlc
    ffmpeg-vpl.ffmpeg-qsv
    nodePackages.bash-language-server
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    unstable.wineWowPackages.stable
    unstable.lutris
    unstable.winetricks
  ];

  programs = {
    kdeconnect.enable = true;
    steam.enable = true;
    partition-manager.enable = true;
    nix-ld.enable = true;
  };

  services.teamviewer.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.foldingathome = {
    enable = true;
    user = "Honi2002";
    team = 223518;
    extraArgs = [ "--password=Password" "--web-allow" "172.20.0.0/16" ];
    daemonNiceLevel = 19;
  };
  #   services.nebula.networks.nebulaHonermann.settings.firewall = {
  #     inbound = [{
  #       port = "36330";
  #       proto = "tcp";
  #       host = "any";
  #     }];
  #   };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    polkit-1.u2fAuth = true;
  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
