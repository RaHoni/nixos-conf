{ config, pkgs, lib, home-manager-stable, ... }:
with lib;
{
  imports = [ ./../default.nix ./plasma.nix ];
  #  home.stateVersion = "23.05";
  programs.kate.lsp.customServers = {
    nix = {
      command = [ "rnix-lsp" ];
      highlightingModeRegex = "^nix$";
    };
  };

  home.packages = with pkgs; [
    qalculate-gtk
    nextcloud-client
  ];

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
    grabKeyboardAndMouse = false;
    maxCacheTtl = 604800;
    defaultCacheTtl = 604800;
  };

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };

    git = {
      userName = "RaHoni";
      userEmail = "honisuess@gmail.com";
      signing = {
        key = "54D11CB37C713D5457ACF0C35962F3E9516FD551";
        signByDefault = true;
      };
      extraConfig = {
        merge.tool = "kdiff3";
      };
    };
  };
}
