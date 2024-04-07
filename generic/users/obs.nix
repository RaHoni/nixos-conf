{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-move-transition
      waveform
      obs-pipewire-audio-capture
    ];
  };
}
