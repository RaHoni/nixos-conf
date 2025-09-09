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
    extraSetFlags = [ "--advertise-exit-node" ];
  };
}
