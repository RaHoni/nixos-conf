{ config, ... }:
let
  secrets = config.sops.secrets;
in
{
  sops.secrets = {
    "bacula/cacert" = { };
    dir-cert.sopsFile = ../secrets/bacula/dir.yaml;
    dir-key.sopsFile = ../secrets/bacula/dir.yaml;
    bacula-dir-password.sopsFile = ../secrets/bacula/clients/dir.yaml;
    bacula-lenovo-linux-password.sopsFile = ../secrets/bacula/clients/lenovo-linux.yaml;
    bacula-r-desktop-password.sopsFile = ../secrets/bacula/clients/r-desktop.yaml;
    bacula-surface-password.sopsFile = ../secrets/bacula/clients/surface.yaml;
    bacula-sylvia-fujitsu-password.sopsFile = ../secrets/bacula/clients/sylvia-fujitsu.yaml;
  };


  sops.templates = {
    "dir-fd.conf".file = ./clients/dir-fd.conf;
    "lenovo-linux.conf".file = ./clients/lenovo-linux.conf;
    "r-desktop.conf".file = ./clients/r-desktop.conf;
    "surface.conf".file = ./clients/surface.conf;
    "sylvia-fujitsu.conf".file = ./clients/sylvia-fujitsu.conf;
  };

  services.bacula-dir = {
    enable = true;
    name = "dir.bacula";
    password = "6SqrCDjtrtKavlrEwqP49az5znQQl8a9vv5vXGlfkrTO"; #TODO encrypt and change
    extraConfig = with config.sops; ''
      @${templates."dir-fd.conf".path}
      @${templates."lenovo-linux.conf".path}
      @${templates."r-desktop.conf".path}
      @${templates."surface.conf".path}
      @${templates."sylvia-fujitsu.conf".path}
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.bacula-dir.port ];

}
