{ sops, ... }:
{
  imports = [
    ./autoupgrade.nix
    ./lanzaboote.nix
    ./tailscale.nix
    ./wireguard.nix
    ./ips.nix
    sops
  ];
}
