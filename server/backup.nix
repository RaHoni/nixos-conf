{ config, pkgs, ... }:
{
  services.restic.backups = {
    nextcloud = {
      paths = [ "/nextcloud" ];
      exclude = [
        "files_trashbin"
        "files_versions"
        "appdata_*/preview"
      ];
    };
  };
  systemd.services.nextcloud-backup-snapshot = rec {
    description = "ZFS snapshot for Nextcloud backup";
    before = [ "restic-backups-nextcloud.service" ];
    requiredBy = before;
    partOf = before;
    restartIfChanged = false;
    unitConfig.StopWhenUnneeded = true;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "nextcloud-snapshot-start" ''
        set -euo pipefail

        echo "Creating snapshot"
        mkdir -p /nextcloud

        ${pkgs.zfs}/bin/zfs snapshot MainZFS/Nextcloud@backup
        ${pkgs.util-linux}/bin/mount -t zfs MainZFS/Nextcloud@backup /nextcloud
      '';

      ExecStop = pkgs.writeShellScript "nextcloud-snapshot-stop" ''
        set -euo pipefail

        echo "Cleaning up snapshot"
        ${pkgs.util-linux}/bin/umount /nextcloud
        ${pkgs.zfs}/bin/zfs destroy MainZFS/Nextcloud@backup
        rmdir /nextcloud
      '';
    };
  };

  services = {
    zfs.autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
    mysqlBackup = {
      enable = true;
      location = "/backmeup/mysql";
      databases = [
        "nextcloud"
        "mysql"
      ];
      singleTransaction = true;
      calendar = "23:00";
    };
    postgresqlBackup = {
      enable = true;
      location = "/backmeup/postgresql";
      startAt = "23:00";
    };
  };
}
