{ config, pkgs, ... }:

{
  users.users.jasmine = {
    isNormalUser = true;
    description = "Jasmine Weyck";
    hashedPassword = "$y$j9T$7Qx5qAFdu1Xkd4NfTU8rJ/$Kv3ZG84UfAtQnsBVSlyghLgMOZcU3A8VpaPl5C4yNW/";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "lp"
      "scanner"
    ];
    packages = with pkgs; [
      keepassxc
      kmail
      kleopatra
      whatsapp-for-linux
      ddcutil
      kaddressbook
      yubioath-flutter
      korganizer
      nextcloud-client
    ];
    openssh.authorizedKeys.keyFiles = [
      ../generic/sshPubkeys/support.pub
    ];
  };
}
