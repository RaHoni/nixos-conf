{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib)
    filter
    mkIf
    mkEnableOption
    mkOption
    concat
    mkDefault
    mapAttrs
    ;
  inherit (lib.types) str attrsOf submodule;
  folderCfg = config.myModules.folder;
  folder = map (v: v.directory) (filter (folderCfg: folderCfg.backup) folderCfg.folders);
  files = map (v: v.file) (filter (fileCfg: fileCfg.backup) folderCfg.files);
  cfg = config.myModules.restic;
  hostname = config.networking.hostName;

  restic-options = {
    config = {
      repository = mkDefault "rest:http://server:8080/${cfg.user}/${cfg.repositoryName}";
      passwordFile = mkDefault config.sops.secrets.repo-passwd.path;
      environmentFile = mkDefault config.sops.templates.restic-http-conf.path;
      progressFps = mkDefault 0.1;
      pruneOpts = mkDefault [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
    };
  };
in
{
  options = {
    myModules.restic = {
      enable = mkEnableOption "Enable Restic Backup";
      user = mkOption {
        type = str;
        description = "The user for the rest server";
      };
      repositoryName = mkOption {
        type = str;
        description = "The repo to use for the backup";
      };
    };
    services.restic.backups = mkOption {
      type = attrsOf (submodule restic-options);
    };
  };
  config = mkIf cfg.enable {
    sops = {
      secrets = {
        repo-passwd.sopsFile = self + /secrets/${hostname}/restic.yaml;
        restic-server-pass.sopsFile = self + /secrets/${hostname}/restic.yaml;
      };
      templates.restic-http-conf = {
        content = ''
          RESTIC_REST_PASSWORD='${config.sops.placeholder.restic-server-pass}'
          RESTIC_REST_USERNAME='${cfg.user}'
        '';
      };
    };
    services.restic.backups.important-folders = {
      paths = map (v: "${folderCfg.restic.snapshotPath}${v}") (concat folder files);
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };

      backupPrepareCommand = mkIf folderCfg.restic.makeSnapshot "${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r ${folderCfg.persistenceFolder} ${folderCfg.restic.snapshotPath}";
      backupCleanupCommand = mkIf folderCfg.restic.makeSnapshot "${pkgs.btrfs-progs}/bin/btrfs subvolume delete ${folderCfg.restic.snapshotPath}";

    };

    myModules.folder.folders = mapAttrs (name: value: {
      directory = "/var/cache/restic-backups-${name}";
      backup = false;
    }) config.services.restic.backups;
  };
}
