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
  networking.interfaces.eth0 = {
    wakeOnLan.enable = true;
    useDHCP = true;
    tempAddress = "disabled";
    ipv6.addresses = [
      {
        address = "fd00::2:1";
        prefixLength = 64;
      }
    ];

  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  myModules.autoUpgrade.enable = true;
  myModules.autoUpgrade.allowReboot = false;

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
    kdePackages.filelight
    firefox
    git
    gnupg
    kdePackages.kate
    kdePackages.kdenlive
    libreoffice
    nmap
    signal-desktop
    vlc
    waypipe
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
