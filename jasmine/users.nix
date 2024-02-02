{ config, pkgs, ... }:

{
  users.users.jasmine = {
    isNormalUser = true;
    description = "Raoul Honermann";
    hashedPassword = "$y$j9T$yqw8MgUKrAPSaNh9eStRd1$c7ULqdfI4DBbI0pisoQJ1KmXAQiBASPjhZ9N3RX89UA";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    packages = with pkgs; [
      keepassxc
      kmail
      kleopatra
      whatsapp-for-linux
      ddcutil
      kaddressbook
      yubioath-flutter
      korganizer
    ];
    openssh.authorizedKeys.keyFiles = [
      ../generic/sshPubkeys/support.pub
    ];
  };
}
