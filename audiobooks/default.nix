{ pkgs, ... }:
{
  networking.hostName = "audiobooks";
  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    package = pkgs.unstable.audiobookshelf;
  };

  system.stateVersion = "23.11";
}
