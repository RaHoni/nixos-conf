{ config, ... }:
{
  sops.secrets.tailscale-auth-key = {
    sopsFile = ../secrets/server/tailscale.yaml;
  };
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes"
      "192.168.1.0/24"
    ];

  };
  environment.persistence."/permament".directories = [ "/var/lib/tailscale" ];
}
