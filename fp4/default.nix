{ pkgs, config, ... }:
{
  system.stateVersion = "23.11";
  enviroment.packages = with pkgs; [
    git
    nano
    gh
  ];
}
