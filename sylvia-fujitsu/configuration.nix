# Edit this configuration file to define what shou:wqld be installed on
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  networking.hostName = "sylvia-fujitsu"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = lib.mkForce "";
  };

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sylvia = {
    isNormalUser = true;
    description = "Sylvia Honermann";
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
    openssh.authorizedKeys = {
      keyFiles = [
        ../generic/sshPubkeys/id_rsa_sylvia.pub
        ../generic/sshPubkeys/ch-fujitsu.pub
      ];
    };
    initialPassword = "12345678";
  };
  users.mutableUsers = true;

  # Enable automatic login for the user.
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
      keepassxc

      # Multimedia
      audacity
      kaffeine # libVLC Optionen: Default: --no-video-title-show  Optionale Ergänzungen: -V xcb_xv  oder  -V xcb_glx:w
      vlc # Zielpfad: /run/current-system/sw/share/soundfonts/
      # Bereich vdr
      # rapVdr # Alternative TV-Software zu KAFFEINE (und SERVICE)
      # vdrPlugins.femon
      # vdrPlugins.text2skin
      # vdrPlugins.streamdev
      # vdrPlugins.epgsearch
      # ENDE Bereich vdr
      aribb24 # Für m2t Video-Stream (TV-Karte)
      aribb25 # Für m2t Video-Stream (TV-Karte)
      avidemux # Aufruf bei Wayland mit der option --platform 'xcb'
      tvbrowser
      musescore

      # Tools und Hilfsprogramme
      neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      nmap
      toybox
      at # Befehl für zeigesteuerte VLC Aufnahmen (und SERVICE)
      sqlite # Bearbeiten von KAFFEINE Datenbanken
      ffmpeg
      kdePackages.filelight
      wol
      wget
      coreutils
      soundconverter
      mp3splt
      vdhcoapp # Für Video DownloadHelper AddOn Firefox

      # KDE-Programme
      kdePackages.partitionmanager
      # -----------------------
      kdePackages.pim-data-exporter # Import und Export von DATEN aus KMail
      kdePackages.akonadi-import-wizard
      kcalc
      ksystemlog
      kdePackages.kleopatra

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  hardware.sane.enable = true; # enables support for SANE scanners
  #  users.users.christoph.extraGroups = [ "scanner" "lp" ];

  # Teamviewer
  services.teamviewer.enable = true;

  # KDE-Connect
  programs.kdeconnect.enable = true;

  # ssh mit Keys (KeePassXC) nutzbar machen
  programs.ssh.startAgent = true;

  # Bluetooth Funktion aktivieren
  hardware.bluetooth.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
