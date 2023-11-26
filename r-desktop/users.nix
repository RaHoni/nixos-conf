{ config, pkgs, ... }:

{
  users.users.raoul = {
    isNormalUser = true;
    description = "Raoul Honermann";
    hashedPassword = "$y$j9T$2qmWuo6/DJXoG.45LLjDX/$Y/NnNHfsQXULwubyI1lPavjfe3fYv/KTWMR4aPLhsSB";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    packages = with pkgs; [
      keepassxc
      jetbrains.webstorm
      jetbrains.idea-ultimate
      jetbrains.clion
      jetbrains.pycharm-professional
      kmail
      nixos-generators
      kleopatra
      whatsapp-for-linux
      rnix-lsp
      gh
      tetex
      nixpkgs-fmt
      pre-commit
      maliit-keyboard
      jq
      kdiff3
      sops
      kaddressbook
      yubioath-flutter
      nebula
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/3EQ9XhwTdsWUSmpBfjqKxPFfeFg/RArJ1uZSZf3fm Surface"
    ];
  };
  users.users.ffmpeg.isNormalUser = true;
  users.users.ffmpeg = {
    description = "This user is used for hardware AV1 encoding.";
    openssh.authorizedKeys.keyFiles = [ ../generic/sshPubkeys/id_ffmpeg.pub ];
  };
}
