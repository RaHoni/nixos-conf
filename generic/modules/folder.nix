{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types)
    str
    nullOr
    listOf
    coercedTo
    bool
    submodule
    ;
  cfg = config.myModules.folder;
  dirOpts = {
    options = {
      user = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          If the directory doesn't exist in persistent
          storage it will be created and owned by the user
          specified by this option.
        '';
      };
      group = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          If the directory doesn't exist in persistent
          storage it will be created and owned by the
          group specified by this option.
        '';
      };
      mode = mkOption {
        type = nullOr str;
        example = "0700";
        default = null;
        description = ''
          If the directory doesn't exist in persistent
          storage it will be created with the mode
          specified by this option.
        '';
      };
      directory = mkOption {
        type = str;
        description = ''
          The path to the directory.
        '';
      };
    };
  };
  commenOpts = {
    options = {
      backup = mkOption {
        type = bool;
        default = true;
        description = "Whether to backup this path";
      };
      persistent = mkOption {
        type = bool;
        default = true;
        description = "Whether to store this folder on persistent storage";
      };
    };
  };
  fileOpts = {
    options = {
      file = mkOption {
        type = str;
        description = "The file path";
      };
    };
  };
  dir = submodule [
    dirOpts
    commenOpts
  ];
  file = submodule [
    fileOpts
    commenOpts
  ];
in
{
  options.myModules.folder = {
    persistenceFolder = mkOption {
      type = str;
      default = "";
      description = "Which path the persistent storage is";
    };
    restic = rec {
      enable = mkEnableOption "Enable backup via restic";
      makeSnapshot = mkOption {
        type = bool;
        default = cfg.persistenceFolder != "";
        defaultText = lib.literalExpression ''cfg.persistenceFolder != ""'';
      };
      snapshotPath = mkOption {
        type = str;
        default =
          if (cfg.restic.makeSnapshot) then "${cfg.persistenceFolder}-snap" else cfg.persistenceFolder;
        defaultText = lib.literalExpression ''if (cfg.restic.makeSnapshot) then "${cfg.persistenceFolder}-snap" else cfg.persistenceFolder'';
      };
    };
    folders = mkOption {
      type = listOf (coercedTo str (d: { directory = d; }) dir);
      default = [ ];
      description = ''
        Directories to bind mount to persistent storage.
      '';
    };
    files = mkOption {
      default = [ ];
      type = listOf (coercedTo str (p: { file = p; }) file);
    };
  };
}
