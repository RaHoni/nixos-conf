{ config, ... }:
let
  secrets = config.sops.secrets;
  owner = config.users.users.bacula.name;
  group = config.users.groups.bacula.name;
in
{
  sops.secrets = {
    "bacula/cacert" = {
      inherit owner group;
    };
    sd-cert = {
      sopsFile = ../secrets/bacula/sd.yaml;
      inherit owner group;
    };
    sd-key = {
      sopsFile = ../secrets/bacula/sd.yaml;
      inherit owner group;
    };
  };
  services.bacula-sd = {
    enable = true;
    name = "sd.bacula";
    port = 9103;
    tls = {
      enable = true;
      require = true;
      caCertificateFile = secrets."bacula/cacert".path;
      certificate = secrets.sd-cert.path;
      key = secrets.sd-key.path;
    };
    director."dir.bacula" = {
      password = "0OxyOlPrvDZW0Rw4BFByZOLh3ncTgZ3+niN7bL0Q";
      tls = {
        enable = true;
        require = true;
        verifyPeer = true;
        allowedCN = [ "dir.bacula" ];
        caCertificateFile = secrets."bacula/cacert".path;
        certificate = secrets.sd-cert.path;
        key = secrets.sd-key.path;
      };
    };

    device.FileChgr1-Dev1 = {
      mediaType = "File1";
      archiveDevice = "/var/bacula";
      extraDeviceConfig = ''
        LabelMedia = yes;                   # lets Bacula label unlabeled media
        Random Access = Yes;
        AutomaticMount = yes;               # when device opened, read it
        RemovableMedia = no;
        AlwaysOpen = no;
      '';
    };

    autochanger.FileChgr1 = {
      devices = [ "FileChgr1-Dev1" ];
      changerDevice = "/dev/null";
      changerCommand = "";
    };

    extraMessagesConfig = ''
      director = dir.bacula = all
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.bacula-sd.port ];
}
