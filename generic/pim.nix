{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs.libsForQt5; [
    kdepim-addons
    kdepim-runtime
    kdeplasma-addons
    akonadi
    akonadi-calendar
    akonadi-calendar-tools
    akonadi-contacts
    akonadi-search
  ];
}
