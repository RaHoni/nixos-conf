{ ... }:
{
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    extraConfig.pipewire."10-echo-cancel"."context.modules" = [
      {
        name = "libpipewire-module-echo-cancel";
        args = {
          # library.name  = aec/libspa-aec-webrtc
          # node.latency = 1024/48000
          source.props = {
            node.name = "Echo Cancellation Source";
          };
          sink.props = {
            node.name = "Echo Cancellation Sink";
          };
        };
      }
    ];
  };
}
