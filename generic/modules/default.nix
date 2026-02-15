{ sops, ... }:
{
  imports = [
    ./autoupgrade.nix
    ./folder.nix
    ./ips.nix
    ./lanzaboote.nix
    ./persistence.nix
    ./restic.nix
    ./tailscale.nix
    ./wireguard.nix
    sops
  ];
}
