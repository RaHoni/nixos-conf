{ config, pkgs, lib, home-manager-stable, plasma-manager, ... }:
with lib;
{
  imports = [ ./../default.nix ./plasma.nix ];
  home.stateVersion = "23.05";

  programs = {
    gpg.settings =
      {

        ignore-cache-for-signing = false;
        min-passphrase-len = 9;
        max-cache-ttl = 1000000;
        default-cache-ttl = 604800;
      };

    git = {
      enable = true;
      userName = "RaHoni";
      userEmail = "honisuess@gmail.com";
      signing = {
        key = "54D11CB37C713D5457ACF0C35962F3E9516FD551";
        signByDefault = true;
      };
      extraConfig = {
        push = { autoSetupRemote = true; };
        pull = { rebase = true; };
      };
    };
  };
}
