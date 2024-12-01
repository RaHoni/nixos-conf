{ pkgs, lib, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      pkgs.ffmpeg-vpl.vpl-gpu-rt
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    INTEL_MEDIA_RUNTIME = "ONEVPL";
    LIBVA_DRIVER_NAME = "iHD";
    ONEVPL_SEARCH_PATH = lib.strings.makeLibraryPath [ pkgs.ffmpeg-vpl.vpl-gpu-rt ];
  };

}
