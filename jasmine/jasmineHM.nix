{ ... }:
{
  imports = [ ./../generic/users ];
  home.stateVersion = "23.11";
  programs.thunderbird.enable = true;
}
