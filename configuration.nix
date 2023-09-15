# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  inherit (builtins) concatStringsSep;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./bacula.nix
      #./nextcloud.nix
      #./copy_usb.nix
      ./users.nix
#       <home-manager/nixos>
    ];

  nix.nixPath =
    # Prepend default nixPath values.
    options.nix.nixPath.default ++
    # Append our nixpkgs-overlays.
    [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ]
  ;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "surface-raoul-nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];

    fontconfig.defaultFonts = {
      serif = ["MesloLGS NF Regular"];
      sansSerif = ["MesloLGS NF Regular"];
      monospace = [ "MesloLGS NF Monospace"];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "deadacute";
  };

  hardware.bluetooth.enable = true;

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  nixpkgs.overlays = [ (final: prev: {
    zsh-powerlevel10k = prev.zsh-powerlevel10k.overrideAttrs {
#    pname = "powerlevel10k-raoul";
       installPhase = ''
       install -D powerlevel10k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
       install -D powerlevel9k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
       install -D config/* --target-directory=$out/share/zsh/themes/powerlevel10k/config
       install -D internal/* --target-directory=$out/share/zsh/themes/powerlevel10k/internal
       cp -R gitstatus $out/share/zsh/themes/powerlevel10k/gitstatus
       '';
    };
    zsh-nix-shell = prev.zsh-nix-shell.overrideAttrs {
    installPhase = ''
      install -D nix-shell.plugin.zsh --target-directory=$out/share/zsh/plugins/nix-shell
      install -D scripts/* --target-directory=$out/share/zsh/plugins/nix-shell/scripts
    '';
  };
    }
  ) ];

  programs.zsh = {
    enable = true;


#      oh-my-zsh = {
    ohMyZsh = {
      enable = true;
      customPkgs = with pkgs; [zsh-nix-shell zsh-powerlevel10k];
      plugins = [ "git" "sudo" "nix-shell"];
      theme = "powerlevel10k/powerlevel10k";
    };
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        upgrade = "sudo nixos-rebuild switch --upgrade";
      };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      xournalpp
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
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  #   enableSSHSupport = true;
  };
  hardware.gpgSmartcards.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  programs.kdeconnect.enable = true;
  system.autoUpgrade.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

