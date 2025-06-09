{
  config,
  pkgs,
  lib,
  home-manager-stable,
  ...
}:
with lib;
{
  imports = [
    ./../default.nix
    ../raoul.nix
  ];
  #  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    anki
    qalculate-gtk
    nextcloud-client
    signal-desktop
    wl-clipboard-x11
    wl-clipboard
    (makeAutostartItem {
      name = "com.nextcloud.desktopclient.nextcloud";
      package = nextcloud-client;
    })
    (makeAutostartItem {
      name = "signal";
      package = signal-desktop;
    })
    (makeAutostartItem {
      name = "com.github.xeco23.WasIstLos";
      package = whatsapp-for-linux;
    })
    (makeAutostartItem {
      name = "org.keepassxc.KeePassXC";
      package = keepassxc-autotype;
    })
  ];

  services.gpg-agent = {
    enable = true;
    grabKeyboardAndMouse = false;
    maxCacheTtl = 604800;
    defaultCacheTtl = 604800;
  };

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };

    firefox = {
      enable = true;
      nativeMessagingHosts = with pkgs; [
        vdhcoapp
        keepassxc-autotype
        kdePackages.plasma-browser-integration
      ];
    };

    thunderbird = {
      enable = true;
      profiles.main = {
        withExternalGnupg = true;
        isDefault = true;
      };
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
