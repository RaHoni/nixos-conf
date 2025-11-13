{ config, pkgs, ... }:
let
  launcher = pkgs.writeScriptBin "launcher" ''
    ${pkgs.systemd}/bin/systemctl start usbcopy@$(${pkgs.systemd}/bin/systemd-escape -p $1)
  '';
in
{

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb",ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1234", ACTION=="add", RUN+="${pkgs.bash}/bin/bash ${launcher}/bin/launcher $devnode"
    SUBSYSTEMS=="usb",ATTRS{idVendor}=="346d", ATTRS{idProduct}=="5678", ACTION=="add", RUN+="${pkgs.bash}/bin/bash ${launcher}/bin/launcher $devnode"
  '';

  systemd.services."usbcopy@" = {
    enable = true;
    path = [
      pkgs.dosfstools
      pkgs.util-linux
    ];
    description = "Renames fat32 patition and copys /usbcopy to it.";
    script = (builtins.readFile ./copy_usb.sh);
    scriptArgs = "%i";
  };
}
