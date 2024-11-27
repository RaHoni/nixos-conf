{ config, pkgs, ... }:

{
  users.groups = {
    raoul = {
      gid = 1000;
    };
  };
  users.users.raoul = {
    uid = 1000;
    isNormalUser = true;
    description = "Raoul Honermann";
    hashedPassword = "$y$j9T$2qmWuo6/DJXoG.45LLjDX/$Y/NnNHfsQXULwubyI1lPavjfe3fYv/KTWMR4aPLhsSB";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "render"
      "raoul"
      "dialout"
      "adbusers"
      "video"
      config.users.groups.keys.name
    ];
    packages = with pkgs; [
      keepassxc
      jetbrains.webstorm
      jetbrains.idea-ultimate
      jetbrains.clion
      jetbrains.pycharm-professional
      nixos-generators
      kleopatra
      whatsapp-for-linux
      gh
      tetex
      nixpkgs-fmt
      pre-commit
      maliit-keyboard
      nixos-anywhere
      jq
      kdiff3
      sops
      yubioath-flutter
      spotify
      nebula
      platformio-core
      android-studio
      prismlauncher
      discord
      jameica
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/3EQ9XhwTdsWUSmpBfjqKxPFfeFg/RArJ1uZSZf3fm Surface"
    ];
  };
  users.users.ffmpeg = {
    isSystemUser = true; # required if we want UID < 1000
    uid = 900; # Matches old setup and hides it from sddm
    extraGroups = [
      "render"
      "video"
    ];

    # things that isNormalUser would give us by default:
    group = "users";
    createHome = true;
    home = "/home/ffmpeg";
    homeMode = "700";
    useDefaultShell = true;
    description = "This user is used for hardware AV1 encoding.";
    openssh.authorizedKeys.keyFiles = [ ../generic/sshPubkeys/id_ffmpeg.pub ];
  };
}
