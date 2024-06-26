{ pkgs, lib, inputs, nixpkgs-ffmpeg, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./users.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;

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

  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.neovim.defaultEditor = true;
  programs.noisetorch.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      pkgs.ffmpeg-vpl.vpl-gpu-rt
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    INTEL_MEDIA_RUNTIME = "ONEVPL";
    LIBVA_DRIVER_NAME = "iHD";
    ONEVPL_SEARCH_PATH = lib.strings.makeLibraryPath [ pkgs.ffmpeg-vpl.vpl-gpu-rt ];
  };

  # Configure console keymap
  console.keyMap = "de";


  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint gutenprintBin epson-escpr2 ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
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
    waypipe
    unstable.lutris
    unstable.winetricks
    inputs.streamdeck-obs.packages.x86_64-linux.streamdeck-obs
    kdePackages.kdenlive
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
    enable = false;
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
    sudo.sshAgentAuth = true;
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
