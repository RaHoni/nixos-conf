{ pkgs, config, ... }:
{
  enviorment.systemPackages = with pkgs; [
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
}
