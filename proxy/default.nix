{
  lib,
  config,
  cloudflare-api-key,
  ...
}:
{
  #proxmoxLXC.manageNetwork = lib.mkForce true;
  imports = [ ../generic/proxy.nix ];

  services = rec {
    automx2 = {
      enable = true;
      domain = "honermann.info";
      settings = {
        provider = "Fam. Honermann";
        domains = [ "honermann.info" ];
        servers = [
          {
            type = "imap";
            name = "mail.honermann.info";
          }
          {
            type = "smtp";
            name = "mail.honermann.info";
          }
        ];
      };
    };
    nginx.virtualHosts."autoconfig.${automx2.domain}" =
      let
        acmePath = "/var/lib/acme/autoconfig.${automx2.domain}";
      in
      {
        enableACME = lib.mkForce false;
        sslCertificate = "${acmePath}/fullchain.pem";
        sslCertificateKey = "${acmePath}/key.pem";
        sslTrustedCertificate = "${acmePath}/chain.pem";
      };
  };

  services.cloudflare-dyndns = {
    enable = true;
    ipv4 = false;
    ipv6 = true;
    domains = [ "honermann.info" ];
    apiTokenFile = cloudflare-api-key;
  };

  networking = {
    hostName = "ssl-proxy";
    enableIPv6 = true;
    useHostResolvConf = false;
    tempAddresses = "disabled";
    defaultGateway.address = config.myModules.ips.gateway.ipv4.address;
    interfaces.eth0 = {
      ipv4 = {
        addresses = [ config.myModules.ips.ssl-proxy.ipv4 ];
      };
    };
    firewall = {
      allowPing = true;
      allowedTCPPorts = [
        80
        443
      ];
      #enable = lib.mkForce false;
    };
  };
  system.stateVersion = "23.11";
}
