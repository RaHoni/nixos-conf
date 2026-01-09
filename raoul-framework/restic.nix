{ config, ... }:
{
  sops = {
    secrets = {
      repo-passwd.sopsFile = ../secrets/raoul-framework/restic.yaml;
      restic-server-pass.sopsFile = ../secrets/raoul-framework/restic.yaml;
    };
    templates.restic-http-conf = {
      content = ''
        RESTIC_REST_PASSWORD='${config.sops.placeholder.restic-server-pass}'
        RESTIC_REST_USERNAME=raoul
      '';
    };
  };
  services.restic.backups.home = {
    repository = "rest:http://server:8080/raoul/framework";
    passwordFile = config.sops.secrets.repo-passwd.path;
    environmentFile = config.sops.templates.restic-http-conf.path;
    paths = [ "/home/raoul" ];
    exclude = [
      "/var/cache"
      "/home/*/.cache"
      ".git"
      ".nsfw/*/game"
      ".local/share/Trash"
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
  };
}
