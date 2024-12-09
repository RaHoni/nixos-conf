{ config, ... }:
{
  sops.secrets.github-runner-key.sopsFile = ../secrets/r-desktop/github.yaml;
  services.github-runners.runner1 = {
    enable = true;
    tokenFile = config.sops.secrets.github-runner-key.path;
    url = "https://github.com/RaHoni/nixos-conf";
  };
}
