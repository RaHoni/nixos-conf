{ config, pkgs, ... }:
let
  hostname = config.networking.hostName;
  defaultRestic = {
    repository = "rest:http://server:8080/raoul/server";
    passwordFile = config.sops.secrets.repo-passwd.path;
    environmentFile = config.sops.templates.restic-http-conf.path;
    inhibitsSleep = true;
    progressFps = 0.1;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
  };
in
{
  environment.persistence."/permament".directories = [
    "/var/cache/restic-backups-nextcloud"
  ];
  sops = {
    secrets = {
      repo-passwd.sopsFile = ../secrets/${hostname}/restic.yaml;
      restic-server-pass.sopsFile = ../secrets/${hostname}/restic.yaml;
    };
    templates.restic-http-conf = {
      content = ''
        RESTIC_REST_PASSWORD='${config.sops.placeholder.restic-server-pass}'
        RESTIC_REST_USERNAME=raoul
      '';
    };
  };
  services.restic.backups = {
    nextcloud = defaultRestic // {
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

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };
}
