{ config, pkgs, ... }:

{
  users.users.raoul = {
    isNormalUser = true;
    description = "Raoul Honermann";
    hashedPassword = "$y$j9T$2qmWuo6/DJXoG.45LLjDX/$Y/NnNHfsQXULwubyI1lPavjfe3fYv/KTWMR4aPLhsSB";
    extraGroups = [ "networkmanager" "wheel" "i2c" "adbuser"];
    packages = with pkgs; [
      keepassxc
      jetbrains.webstorm
      jetbrains.gateway
      kmail
      nixos-generators
      kleopatra
      whatsapp-for-linux
      ddcutil
      #rnix-lsp
      gh
      nixpkgs-fmt
      pre-commit
      maliit-keyboard
      jq
      kdiff3
      sops
      kaddressbook
      yubioath-flutter
      nebula
      korganizer

      texlive.combined.scheme-full
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/3EQ9XhwTdsWUSmpBfjqKxPFfeFg/RArJ1uZSZf3fm Surface"
    ];
  };
}
