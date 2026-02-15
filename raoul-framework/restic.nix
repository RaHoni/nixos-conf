{ config, pkgs, ... }:
{
  myModules.restic = {
    enable = true;
    user = "raoul";
    repositoryName = "framework";
  };
  services.restic.backups.home = {
    paths = [ "/home-snap/raoul" ];
    exclude = [
      "/var/cache"
      "/home/*/.cache"
      ".git"
      ".nsfw/*/game"
      ".local/share/Trash"
      "baloo/index"
    ];
    extraBackupArgs = [
      "--exclude-caches"
      "--exclude-if-present"
      ".excludeme"
    ];
    inhibitsSleep = true;
    backupPrepareCommand = "${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /home /home-snap";
    backupCleanupCommand = "${pkgs.btrfs-progs}/bin/btrfs subvolume delete /home-snap";
  };
}
