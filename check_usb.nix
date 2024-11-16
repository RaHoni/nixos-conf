{ config, pkgs, ... }:
let
  launcher = pkgs.writeScriptBin "launcher" ''
    ${pkgs.systemd}/bin/systemctl start usbcheck@$(${pkgs.systemd}/bin/systemd-escape -p $1)
  '';
in
{



  services.udev.extraRules = ''SUBSYSTEMS=="usb",ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1234", ACTION=="add", RUN+="${pkgs.bash}/bin/bash ${launcher}/bin/launcher $devnode"'';

  systemd.services."usbcheck@" = {
    enable = true;
    path = [ pkgs.dosfstools pkgs.util-linux ];
    description = "Test the USB Sticks failed get ejected to blink indefintly";
    script = (builtins.readFile ./check_usb.sh);
    scriptArgs = "%i";
  };
}
