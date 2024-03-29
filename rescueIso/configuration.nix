{ pkgs, config, lib, ... }:
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
  
  #Enable Plasma Desktop Manager
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure console Keymap
  console.keyMap = "de";

  users.users.live.openssh.authorizedKeys.keyFiles = [
    ../generic/sshPubkeys/support.pub
  ];

  networking.firewall.enable = false;

  system.stateVersion = "23.11";

  fileSystems."/persitent" = {
    label = "Ventoy_BTRFS";
    fsType = "btrfs";
    options = [ "subvol=nixos" "compress=zstd" ];
  };

}
