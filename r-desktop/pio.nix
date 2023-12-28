{config,pkgs,...}:
{

  services.udev.packages = [ 
    pkgs.platformio-core.udev
    pkgs.openocd
  ];

}
