{ config, ... }:
{
  sops.secrets.github-runner-key.sopsFile = ../secrets/r-desktop/github.yaml;
  services.github-runners.nixos-runner = {
    enable = true;
    extraLabels = [ "x86_64-linux" ];
    tokenFile = config.sops.secrets.github-runner-key.path;
    url = "https://github.com/RaHoni/nixos-conf";
  };
}
