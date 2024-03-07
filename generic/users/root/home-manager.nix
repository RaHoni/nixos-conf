{ config, ... }:
{
  home.homeDirectory = "/root";
  imports = [ ./../default.nix ];
  #home.stateVersion = "23.05";
}
