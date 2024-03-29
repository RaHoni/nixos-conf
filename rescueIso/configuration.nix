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

  fileSystems."/persitent" = {
    label = "Ventoy_BTRFS";
    fsType = "btrfs";
    options = [ "subvol=nixos" "compress=zstd" ];
  };

}
