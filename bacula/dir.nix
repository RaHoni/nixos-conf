{ config, pkgs, lib, ... }:
let
  secrets = config.sops.secrets;
  libDir = "/var/lib/bacula";
in
{
  sops.secrets = {
    "bacula/cacert".path = "/etc/bacula/bacula-ca.cert";
    dir-cert.sopsFile = ../secrets/bacula/dir.yaml;
    dir-cert.path = "/etc/bacula/dir.cert";
    dir-key.sopsFile = ../secrets/bacula/dir.yaml;
    dir-key.path = "/etc/bacula/dir.key";
    bacula-dbpass.sopsFile = ../secrets/bacula/dir.yaml;
    bacula-dir-password.sopsFile = ../secrets/bacula/clients/dir.yaml;
    bacula-lenovo-linux-password.sopsFile = ../secrets/bacula/clients/lenovo-linux.yaml;
    bacula-r-desktop-password.sopsFile = ../secrets/bacula/clients/r-desktop.yaml;
    bacula-surface-password.sopsFile = ../secrets/bacula/clients/surface.yaml;
    bacula-sylvia-fujitsu-password.sopsFile = ../secrets/bacula/clients/sylvia-fujitsu.yaml;
  };


  sops.templates = {
    "dir.conf".content = ( builtins.readFile ./bacula-dir.conf );
    "dir-fd.conf".content = ( builtins.readFile ./clients/dir-fd.conf );
    "lenovo-linux.conf".content = ( builtins.readFile ./clients/lenovo-linux.conf );
    "r-desktop.conf".content = ( builtins.readFile ./clients/r-desktop.conf );
    "surface.conf".content = ( builtins.readFile ./clients/surface.conf );
    "sylvia-fujitsu.conf".content = ( builtins.readFile ./clients/sylvia-fujitsu.conf );
  };

  services.bacula-dir = {
    enable = true;
    name = "dir.bacula";
    password = "6SqrCDjtrtKavlrEwqP49az5znQQl8a9vv5vXGlfkrTO"; #TODO encrypt and change
    extraMessagesConfig = ''
      mailcommand = "bsmtp -f bacula-dir -s \"Bacula: %t %e of %c %l\" %r"
      operatorcommand = "bsmtp -f bacula-dir -s \"Bacula: Intervention needed for %j\" %r"
      mail on error = raoul.honermann@web.de,christoph.honermann@web.de = all, !skipped
      operator = raoul.honermann@web.de = mount
      console = all, !skipped, !saved
      catalog = all
    '';
    extraConfig = with config.sops; ''
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
        TLS CA Certificate File = ${config.sops.secrets."bacula/cacert".path}
        # This is a server certificate, used for incoming
        # console connections.
        TLS Certificate = ${config.sops.secrets.dir-cert.path}
        TLS Key = ${config.sops.secrets.dir-key.path}
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
