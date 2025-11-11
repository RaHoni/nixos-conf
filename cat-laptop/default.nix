{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  local.tailscale = {
    enable = true;
    extern = true;
  };

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libreoffice
    wget
    firefox
    gimp
    krita
    discord
  ];

  hardware.bluetooth.enable = true;

  myModules.autoUpgrade = {
    enable = true;
    delayForInternet = true;
  };

  networking.hostName = "cat-laptop";
  networking.networkmanager.enable = true;

  programs.kdeconnect.enable = true;

  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    libinput.enable = true;
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    teamviewer.enable = true;

  };

  users.users.cathach = {
    isNormalUser = true;
    description = "Cathach";
    extraGroups = [
      "wheel"
      "lp"
      "scanner"
    ];
    hashedPassword = "$y$j9T$WRFw5PAbeN71qkFQ7XO3//$X5ZY3bnserHXd4CvXnI11N/0MejTp.ZFJDEiQokDz45";
    openssh.authorizedKeys.keyFiles = [
      ../generic/sshPubkeys/support.pub
    ];
  };

  system.stateVersion = "24.11";
}
