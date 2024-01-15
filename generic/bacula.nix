{ config, private-nixpkgs, lib, ... }:
{
  options = {
  services.bacula-fd.shutdown-on-finish = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = lib.mdDoc ''Enable the generation of a shutdown script for this host.''; 
  };
  };
  config = {
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
  networking.firewall.allowedTCPPorts = [ 9102 ];

  envirement.etc."bacula/shutdown.sh".source = ./shutdown.sh;
};
}
