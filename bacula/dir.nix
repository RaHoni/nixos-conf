{ config, pkgs, lib, inputs, ... }:
let
  secrets = config.sops.secrets;
  templates = config.sops.templates;
  placeholders = config.sops.placeholder;
  libDir = "/var/lib/bacula";
  group = config.users.users.bacula.group;
  user = config.users.users.bacula.name;

  replaceTemplate = file: (
    pkgs.substituteAll {
      src = file;
      dbpass = placeholders.bacula-dbpass;
      dirPassword = placeholders.bacula-dir-password;
      lenovoPassword = placeholders.bacula-lenovo-linux-password;
      rdesktopPassword = placeholders.bacula-r-desktop-password;
      surfacePassword = placeholders.bacula-surface-password;
      sylviaFujitsuPassword = placeholders.bacula-sylvia-fujitsu-password;
    }
  );
in
{
  disabledModules = [ "services/backup/bacula.nix" ];
  imports = [ "${inputs.nixpkgs-bacula}/nixos/modules/services/backup/bacula.nix" ];
  sops.secrets = {
    "bacula/cacert" = {
      path = "/etc/bacula/bacula-ca.cert";
      owner = user;
      group = group;
    };
    dir-cert = {
      sopsFile = ../secrets/bacula/dir.yaml;
      path = "/etc/bacula/dir.cert";
      owner = user;
      group = group;
    };
    dir-key = {
      sopsFile = ../secrets/bacula/dir.yaml;
      path = "/etc/bacula/dir.key";
      owner = user;
      group = group;
    };
    bacula-dbpass.sopsFile = ../secrets/bacula/dir.yaml;
    bacula-dir-password.sopsFile = ../secrets/bacula/clients/dir.yaml;
    bacula-lenovo-linux-password.sopsFile = ../secrets/bacula/clients/lenovo-linux.yaml;
    bacula-r-desktop-password.sopsFile = ../secrets/bacula/clients/r-desktop.yaml;
    bacula-surface-password.sopsFile = ../secrets/bacula/clients/surface.yaml;
    bacula-sylvia-fujitsu-password.sopsFile = ../secrets/bacula/clients/sylvia-fujitsu.yaml;
  };


  sops.templates = {
    "dir.conf".file = ( replaceTemplate ./bacula-dir.conf );
    "dir-fd.conf".file = ( replaceTemplate ./clients/dir-fd.conf );
    "lenovo-linux.conf".file = ( replaceTemplate ./clients/lenovo-linux.conf );
    "r-desktop.conf".file = ( replaceTemplate ./clients/r-desktop.conf );
    "surface.conf".file = ( replaceTemplate ./clients/surface.conf );
    "sylvia-fujitsu.conf".file = ( replaceTemplate ./clients/sylvia-fujitsu.conf );
    "catalog-db-pass.conf".content = ''password = "${placeholders.bacula-dbpass}"'';
  };

  services.bacula-dir = {
    enable = true;
    name = "dir.bacula";
    password = "6SqrCDjtrtKavlrEwqP49az5znQQl8a9vv5vXGlfkrTO"; #TODO encrypt and change
    catalogs.MyCatalog = {
      dbSocket = "/run/mysqld/mysqld.sock";
      password = null;
      extraConfig = "@${templates."catalog-db-pass.conf".path}";
    };
    extraMessagesConfig = ''
      mailcommand = "bsmtp -f bacula-dir -s \"Bacula: %t %e of %c %l\" %r"
      operatorcommand = "bsmtp -f bacula-dir -s \"Bacula: Intervention needed for %j\" %r"
      mail on error = raoul.honermann@web.de,christoph.honermann@web.de = all, !skipped
      operator = raoul.honermann@web.de = mount
      console = all, !skipped, !saved
      catalog = all
    '';
    extraConfig = ''
      # Definition of file Virtual Autochanger device
      Autochanger {
        Name = File1
        # Do not use "localhost" here
        Address = sd.bacula                # N.B. Use a fully qualified name here
        SDPort = 9103
        Password = "0OxyOlPrvDZW0Rw4BFByZOLh3ncTgZ3+niN7bL0Q"
        Device = FileChgr1
        Media Type = File1
        Maximum Concurrent Jobs = 10        # run up to 10 jobs a the same time
        Autochanger = File1                 # point to ourself
        TLS Require = yes
        TLS CA Certificate File = ${secrets."bacula/cacert".path}
        # This is a server certificate, used for incoming
        # console connections.
        TLS Certificate = ${secrets.dir-cert.path}
        TLS Key = ${secrets.dir-key.path}
      }

      @${templates."dir.conf".path} # Additional Configs

      @${templates."dir-fd.conf".path}
      @${templates."lenovo-linux.conf".path}
      @${templates."r-desktop.conf".path}
      @${templates."surface.conf".path}
      @${templates."sylvia-fujitsu.conf".path}
    '';
  };

  systemd.services.bacula-dir = {
    preStart = lib.mkForce ''''; #''
    #if ! test -e "${libDir}/db-created"; then
    #
    #   # populate DB
    #    ${pkgs.bacula}/etc/create_bacula_database mysql
    #    ${pkgs.bacula}/etc/make_bacula_tables mysql
    #    ${pkgs.bacula}/etc/grant_bacula_privileges mysql
    #    touch "${libDir}/db-created"
    #else
    #    ${pkgs.bacula}/etc/update_bacula_tables mysql || true
    #fi
    #  '';
    path = [ pkgs.bash ];
  };
  networking.firewall.allowedTCPPorts = [ config.services.bacula-dir.port ];

}
