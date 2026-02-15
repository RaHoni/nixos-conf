{ config, lib, ... }:
let
  cfg = config.myModules.folder;
  inherit (lib) mkIf filter filterAttrs;
  filterExtras =
    list:
    map (filterAttrs (n: v: (n != "persistent" && n != "backup" && v != null))) (
      filter (folderCfg: folderCfg.persistent) list
    );
in
{
  config.environment =
    if (cfg.persistenceFolder != "") then
      {
        persistence."${cfg.persistenceFolder}" = {
          directories = filterExtras cfg.folders;
          files = filterExtras cfg.files;
        };
      }
    else
      { };
}
