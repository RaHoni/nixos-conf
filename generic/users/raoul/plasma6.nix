{ ... }:
{
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    shortcuts = {
      kwin = {
        "Switch to Next Desktop" = "Meta+Tab";
        "Switch to Previous Desktop" = "Meta+Shift+Tab";
        "Window to Next Desktop" = "Meta+Ctrl+Tab";
        "Window to Previous Desktop" = "Meta+Ctrl+Shift+Tab";
      };
    };

    kwin = {
      virtualDesktops = {
        number = 4;
        rows = 2;
      };
      effects = {
        desktopSwitching.navigationWrapping = true;
        dimAdminMode.enable = true;
      };
    };

  };
}
