{ pkgs, ... }:
{
  services.wyoming = {
    faster-whisper.servers."German" = {
      enable = true;
      language = "de";
      model = "base";
      beamSize = 3;
      uri = "tcp://0.0.0.0:10300";
    };
    openwakeword = {
      enable = true;
      preloadModels = [
        "hey_jarvis"
        "ok_nabu"
        "hey_rhasspy"
      ];
    };
    piper.servers."German" = {
      enable = true;
      voice = "de_DE-thorsten-medium";
      uri = "tcp://0.0.0.0:10200";
    };
  };
  networking.firewall.allowedTCPPorts = [ 10200 10300 10400 ];
}
