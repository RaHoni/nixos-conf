{ pkgs, ... }:
{
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };
  environment.systemPackages = with pkgs.kdePackages; [
    akonadi
    akonadi-calendar
    akonadi-calendar-tools
    akonadi-contacts
    akonadi-search
    calendarsupport
    kaddressbook
    kcalendarcore
    kdepim-addons
    kdepim-runtime
    kdeplasma-addons
    kmail
    korganizer
    libkdepim
    pimcommon
  ];
}
