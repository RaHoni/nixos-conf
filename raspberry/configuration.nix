{ config, pkgs, ... }:
{
  networking.hostName = "raspberry";
  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = true;
  imports = [ ./hardware-configuration.nix ./nebula.nix ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;


  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2OK6+2Gk7zJQH0dPpyl4wNdgzLI9U6VNXZQjFyVfR+ SSH for Raspberry-Pi-Raoul"
    ];
  };

  hardware.bluetooth.enable = true;

  # Configure console keymap
  console.keyMap = "de";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zsh-completions
    git
  ];

  services.openssh.enable = true;

  system.autoUpgrade.flake = "github:RaHoni/nixos-conf";
  system.autoUpgrade.enable = true;


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 53 51821 ];
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
