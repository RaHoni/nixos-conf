{ pkgs, ... }:
{
  myModules.restic = {
    enable = true;
    user = "raoul";
    repositoryName = "tablet";
  };
  services.restic.backups.home = {
    paths = [ "/home-snap/raoul" ];
    pruneOpts = [
      "--group-by"
      "paths"
    ]; # Don't split snapshots based on hostname
    exclude = [
      "/var/cache"
      ".cache"
      ".git"
      ".local/share/Trash"
      "baloo/index"
      "Nextcloud"
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
