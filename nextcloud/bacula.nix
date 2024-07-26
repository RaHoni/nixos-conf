{pkgs, config, ...}:
{
  imports = [ ../generic/bacula.nix ];
  environment.etc = {
    "bacula/backupMysql.sh"= {
      source = ../bacula/backupMysql.sh;
    };
    "bacula/dumpCatalog.sh" = {
      text = ''
        #!/usr/bin/env nix-shell
        #! nix-shell -i bash -p mysql
        mysqldump bacula > /var/lib/bacula/bacula.sql
      '';
      mode = "777";
    };
  };
  services.bacula-fd.director."dir.bacula".password = "vN07/mpGJqcczuHNsuHUW7PNjYwHKle1DVZ/b8yh";
  systemd.services.bacula-fd.path = [ pkgs.mysql ];

}
