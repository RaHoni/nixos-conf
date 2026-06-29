{
  config,
  pkgs,
  lib,
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
    karere
    nextcloud-client
    qalculate-gtk
    signal-desktop
    wl-clipboard
    wl-clipboard-x11
    (makeAutostartItem {
      name = "com.nextcloud.desktopclient.nextcloud";
      package = nextcloud-client;
    })
    (makeAutostartItem {
      name = "signal";
      package = signal-desktop;
    })
    (makeAutostartItem {
      name = "io.github.tobagin.karere";
      package = karere;
    })
    (makeAutostartItem {
      name = "org.keepassxc.KeePassXC";
      package = keepassxc;
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
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      nativeMessagingHosts = with pkgs; [
        keepassxc
        kdePackages.plasma-browser-integration
      ];
    };

    thunderbird = {
      enable = true;
      package = pkgs.thunderbird-esr;
      profiles.main = {
        withExternalGnupg = true;
        isDefault = true;
      };
    };

    git = {
      signing = {
        key = "54D11CB37C713D5457ACF0C35962F3E9516FD551";
        signByDefault = true;
      };
      settings = {
        user = {
          Name = "RaHoni";
          Email = "honisuess@gmail.com";
        };
        merge.tool = "kdiff3";
        "credential \"https://github.com\"".helper =
          "!/etc/profiles/per-user/raoul/bin/gh auth git-credential";
        "credential \"https://gist.github.com\"".helper =
          "!/etc/profiles/per-user/raoul/bin/gh auth git-credential";
      };
    };
  };
}
