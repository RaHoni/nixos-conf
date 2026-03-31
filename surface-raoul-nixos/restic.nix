{ config, pkgs, ... }:
let
  hostname = config.networking.hostName;
in
{
  myModules.restic = {
    enable = true;
    user = "raoul";
    repositoryName = "surface";
  };
  services.restic.backups.home = {
    paths = [ "/home-snap/raoul" ];
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
