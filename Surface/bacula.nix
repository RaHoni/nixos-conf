{ config, ... }:
{
  imports = [ ../generic/bacula.nix ];
  sops.secrets = {
    fd-cert.sopsFile = ../secrets/Surface/bacula.yaml;
    fd-key.sopsFile = ../secrets/Surface/bacula.yaml;
  };
  services.bacula-fd = {
    tls = {
      certificate = config.sops.secrets.fd-cert.path;
      key = config.sops.secrets.fd-key.path;
    };
    director."dir.bacula" = {
      password = "oWwZjE1DOm+ex+pchPyW8ZSPBya4rXShSG6bjB/T";
      tls = {
        certificate = config.sops.secrets.fd-cert.path;
        key = config.sops.secrets.fd-key.path;
      };
    };
  };
}
