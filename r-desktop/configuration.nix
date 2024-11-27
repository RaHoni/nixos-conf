{
  pkgs,
  lib,
  inputs,
  nixpkgs-ffmpeg,
  ...
}:
{
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

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
  };
  system.autoUpgrade = {
    enable = true;
    flake = "github:RaHoni/nixos-conf";
    allowReboot = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.defaultSession = "plasma";

  programs.neovim.defaultEditor = true;
  programs.noisetorch.enable = true;

  services.gvfs.enable = true;
  programs.adb.enable = true;

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
