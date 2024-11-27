{ pkgs, ... }:
let
  incroneFile = pkgs.writeText "incronFFmpeg" ''
    /home/ffmpeg/konvertieren       IN_CLOSE_WRITE  /home/ffmpeg/konvertieren.sh $#
  '';
in
{
  services.incron = {
    enable = true;
    allow = [ "ffmpeg" ];
  };
  system.activationScripts = {
    incron.text = ''cp ${incroneFile} /var/spool/incron/ffmpeg'';
  };
}
