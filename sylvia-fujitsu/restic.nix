{ config, pkgs, ... }:
let
  hostname = config.networking.hostName;
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
        RESTIC_REST_USERNAME=sylvia
      '';
    };
  };
  services.restic.backups.home = {
    repository = "rest:http://server:8080/sylvia/laptop";
    passwordFile = config.sops.secrets.repo-passwd.path;
    environmentFile = config.sops.templates.restic-http-conf.path;
    progressFps = 0.1;
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
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
    backupPrepareCommand = "${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /home /home-snap";
    backupCleanupCommand = "${pkgs.btrfs-progs}/bin/btrfs subvolume delete /home-snap";
  };
}
