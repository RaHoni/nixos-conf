{
  pkgs,
  config,
  lib,
  ...
}:
{
  networking.hostName = "rescueIso";
  environment.systemPackages = with pkgs; [
    testdisk # photorec
    mc
    scalpel
    ddrescue
    ddrescueview
    chntpw # Windows PW
    wipe
    wipefreespace
    memtest86plus
    memtest86-efi
  ];

  sops.age = {
    keyFile = lib.mkForce "/persitent/lib/sops/key.txt";
  };

  i18n.defaultLocale = "de_DE.UTF-8";

  # Configure console Keymap
  console.keyMap = "de";

  users.users.nixos = {
    openssh.authorizedKeys.keyFiles = [
      ../generic/sshPubkeys/support.pub
    ];
    isNormalUser = true;
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../generic/sshPubkeys/support.pub
  ];

  networking.firewall.enable = false;

  system.stateVersion = "23.11";

  fileSystems."/".device = "/dev/sda";
  boot.loader.grub.device = "/dev/sda";
  #  lib.isoFileSystems."/persitent" = {
  #    label = "VentoyBTRFS";
  #    fsType = "btrfs";
  #    neededForBoot = true;
  #    options = [
  #      "subvol=nixos"
  #      "compress=zstd"
  #    ];
  #  };

}
