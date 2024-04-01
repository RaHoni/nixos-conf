{ pkgs, ... }:

{
  users.mutableUsers = false;
  users.users.streaming = {
    isNormalUser = true;
    description = "St. Petronilla Livestreaming";
    hashedPassword = "$y$j9T$YTJ0cUDqutWYa9bg5sG9E.$sMS5zN.zmkSiuW1dr18NQ9KpDnQ/zTRCRv7k61X/RP3";
    extraGroups = [ "networkmanager" "wheel" "i2c" "render" ];
    packages = with pkgs; [
      keepassxc
      ddcutil
      yubioath-flutter
      korganizer
    ];
    openssh.authorizedKeys.keyFiles = [
      ../generic/sshPubkeys/support.pub
    ];
  };
}
