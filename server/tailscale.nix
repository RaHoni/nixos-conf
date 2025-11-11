{ ... }:
{
  local.tailscale = {
    enable = true;
    exit-node = true;
  };

  environment.persistence."/permament".directories = [ "/var/lib/tailscale" ];
}
