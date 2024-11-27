{ ... }:
{
  imports = [
    ./configuration.nix
    ./users.nix
  ];
  system.autoUpgrade = {
    flake = "github:RaHoni/nixos-conf";
    enable = true;
  };

}
