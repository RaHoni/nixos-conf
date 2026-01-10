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
      backupPrepareCommand = ''
        echo "Creating snapshot"
        mkdir /nextcloud
        ${pkgs.zfs}/bin/zfs snapshot MainZFS/Nextcloud@backup
        ${pkgs.util-linux}/bin/mount -t zfs MainZFS/Nextcloud@backup /nextcloud
      '';
      backupCleanupCommand = ''
        ${pkgs.util-linux}/bin/umount /nextcloud
        ${pkgs.zfs}/bin/zfs destroy MainZFS/Nextcloud@backup
        rm -r /nextcloud
      '';
    };
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
  };
}
