{ config, pkgs, modulesPath, ... }:

{
  networking.hostName = "packete";

  environment.systemPackages = [
    pkgs.apacheHttpd
  ];
  services.httpd = {
    enable = true;
    adminAddr = "webmaster@honermann.info";
    virtualHosts.packete = {
      hostName = "packete.honermann.info";
      documentRoot = "/var/www/packete";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.httpd.virtualHosts.packete.documentRoot} 1777 1000 1000 "
  ];

  fileSystems."${config.services.httpd.virtualHosts.packete.documentRoot}" = {
    device = "/export/packete";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export/packete 192.168.2.29/23(rw,sync,no_subtree_check,no_root_squash,anonuid=0,anongid=0)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };


  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 80 ];
    allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  };

  system.stateVersion = "23.05";
}
