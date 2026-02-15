{ config, pkgs, ... }:
{
  myModules.restic = {
    enable = true;
    user = "sylvia";
    repositoryName = "laptop";
  };
  services.restic.backups.home = {
    paths = [ "/home-snap/" ];
    exclude = [
      "/var/cache"
      "/home/*/.cache"
      ".git"
      ".local/share/Trash"
      "baloo/index"
      "/home/sylvia/Nextcloud"
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
