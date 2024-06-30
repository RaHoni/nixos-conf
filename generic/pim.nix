{ pkgs, ... }:
{
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
    korganizer
    libkdepim
    pimcommon
  ];
}
