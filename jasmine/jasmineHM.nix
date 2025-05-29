{ pkgs, ... }:
{
  imports = [ ./../generic/users ];
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    thunderbird
    kdePackages.kate
  ];
}
