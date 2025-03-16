{ ... }:
{
  # enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # if you want to use jack applications, uncomment this
    #jack.enable = true;
  };
}
