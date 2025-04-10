# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  #  boot.loader.systemd-boot.enable = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    memtest86.enable = true;
    default = "saved";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  networking.hostName = "lenovo-linux"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

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
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Für richtigen nvidia Support
  #hardware.graphics.enable = true;
  #services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = lib.mkForce "";
  };

  stylix = {
    enable = true;
    image = ./Hubble_Jubilaeumsbild.jpg;
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 24;
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.christoph = {
    isNormalUser = true;
    description = "Christoph Honermann";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "scanner"
      "video"
    ]; # Manuell ab lp
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "christoph";
  services.displayManager.sddm.autoNumlock = true;

  # Konfiguration zum AUTO-Update über GitHub
  myModules.autoUpgrade.enable = true;

  # Install firefox.
  # Programme mit Optionen
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # "normale" Programme und "KDE" Programme
  environment.systemPackages =
    with pkgs;
    with kdePackages;
    [

      # Produktivität
      libreoffice
      thunderbird
      xsane
      jameica
      gimp
      keepassxc

      # Multimedia
      audacity
      kaffeine # libVLC Optionen: Default: --no-video-title-show  Optionale Ergänzungen: -V xcb_xv  oder  -V xcb_glx:w
      vlc # Zielpfad: /run/current-system/sw/share/soundfonts/
      aribb24 # Für m2t Video-Stream (TV-Karte)
      aribb25 # Für m2t Video-Stream (TV-Karte)
      avidemux # Aufruf bei Wayland mit der option --platform 'xcb'
      tvbrowser
      rosegarden
      lilypond
      qsynth
      fluidsynth
      soundfont-fluid # Zielpfad: /run/current-system/sw/share/soundfonts/
      frescobaldi
      musescore
      kdenlive
      #  midica        # Midi mit Lauftext anzeigen lassen
      handbrake

      # Tools und Hilfsprogramme
      neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      nmap
      usbutils
      pciutils
      toybox
      ffmpeg
      filelight
      kfind
      ventoy
      k3b
      kid3
      obs-studio
      #  clonezilla
      timidity
      wol
      wget
      coreutils
      soundconverter
      mpv # mpv Media Player
      smplayer # SM-Player (Video und Ton)
      mp3splt
      vdhcoapp # Für Video DownloadHelper AddOn Firefox

      # KDE-Programme
      kdePackages.partitionmanager
      # -----------------------
      akonadi
      akonadi-calendar
      akonadi-calendar-tools
      akonadi-contacts
      akonadi-search
      kaddressbook
      kmail
      pimcommon
      libkdepim
      kdepim-addons
      kdepim-runtime
      kdeplasma-addons
      kdePackages.kmail-account-wizard
      kdePackages.calendarsupport
      kcalendarcore
      korganizer
      # -------------------------
      kdePackages.pim-data-exporter # Import und Export von DATEN aus KMail
      kdePackages.akonadi-import-wizard
      kcalc
      ksystemlog
      kleopatra
      # SPIELE:
      kshisen
      kpat
      ksudoku
      katomic
      kmines
      kapman
      kblocks

      # Sonstiges
      gh
      mc
      gocr
      ocrfeeder
      nextcloud-client
      digikam
      signal-desktop
      whatsapp-for-linux
      zoom
      mediathekview
      tvbrowser
      skanlite
      simplescreenrecorder
      vdhcoapp # Im Anschluss als User den Befehl "vdhcoapp install" ausführen
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Drucker / Scanner aktivieren mit Netzwerksuche
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.sane.enable = true; # enables support for SANE scanners
  #  users.users.christoph.extraGroups = [ "scanner" "lp" ];

  # Teamviewer
  services.teamviewer.enable = true;
  # Virtual Box als Host-service
  virtualisation.virtualbox.host = {
    enable = true;
    #enableKvm = true;
  };

  # KDE-Connect
  programs.kdeconnect.enable = true;

  # ssh mit Keys (KeePassXC) nutzbar machen
  programs.ssh.startAgent = true;

  # Bluetooth Funktion aktivieren
  hardware.bluetooth.enable = true;

  # Nächster Eintrag
  # 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
