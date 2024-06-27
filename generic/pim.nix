{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.kdePackages; [
    kdepim-addons
    kdepim-runtime
    kdeplasma-addons
    akonadi
    akonadi-calendar
    akonadi-calendar-tools
    akonadi-contacts
    akonadi-search
    korganizer
    kaddressbook
  ];
}
