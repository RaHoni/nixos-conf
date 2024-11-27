{ config, pkgs, ... }:

{
  users.users.raoul = {
    isNormalUser = true;
    description = "Raoul Honermann";
    hashedPassword = "$y$j9T$2qmWuo6/DJXoG.45LLjDX/$Y/NnNHfsQXULwubyI1lPavjfe3fYv/KTWMR4aPLhsSB";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
    ];
    packages = with pkgs; [
      ddcutil
      #rnix-lsp
      gh
      unstable.keepassxc
      maliit-keyboard
      tetex
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/3EQ9XhwTdsWUSmpBfjqKxPFfeFg/RArJ1uZSZf3fm Surface"
    ];
  };
}
