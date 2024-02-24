{ ... }:
{
  networking.hostName = "audiobooks";
  services.audiobookshelf.enable = true;
  services.audiobookshelf.openFirewall = true;
  services.audiobookshelf.host = "0.0.0.0";

  system.stateVersion = "23.11";
}
