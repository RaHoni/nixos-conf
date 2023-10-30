{ config, private-nixpkgs, ... }:
{
  disabledModules = [ "services/backup/bacula.nix" ];
  imports = [ "${private-nixpkgs}/nixos/modules/services/backup/bacula.nix" ];
  sops.secrets = {
    "bacula/cacert" = { };
    fd-cert.sopsFile = ../secrets/${config.networking.hostName}/bacula.yaml;
    fd-key.sopsFile = ../secrets/${config.networking.hostName}/bacula.yaml;
  };
  services.bacula-fd = {
    enable = true;
    director."dir.bacula" = {
      password = "oWwZjE1DOm+ex+pchPyW8ZSPBya4rXShSG6bjB/T";
      tls = {
        enable = true;
        require = true;
        verifyPeer = true;
        allowedCN = [ "dir.bacula" ];
        caCertificateFile = config.sops.secrets."bacula/cacert".path;
        certificate = config.sops.secrets.fd-cert.path;
        key = config.sops.secrets.fd-key.path;
      };
    };
    tls = {
      enable = true;
      require = true;
      caCertificateFile = config.sops.secrets."bacula/cacert".path;
      certificate = config.sops.secrets.fd-cert.path;
      key = config.sops.secrets.fd-key.path;
    };
  };
}
