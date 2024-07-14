{ ... }:
{
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    shortcuts = {
      kwin = {
        "Switch to Next Desktop" = "Meta+Tab,,Switch to Next Desktop";
        "Switch to Previous Desktop" = "Meta+Shift+Tab,,Switch to Previous Desktop";
        "Window to Next Desktop" = "Meta+Ctrl+Tab,,Window to Next Desktop";
        "Window to Previous Desktop" = "Meta+Ctrl+Shift+Tab,,Window to Previous Desktop";
      };
    };

    configFile.kwinrc = {
      Desktops = {
        Number = 4;
        Rows = 2;
      };
      Windows.RollOverDesktops = true;
    };
  };
}
