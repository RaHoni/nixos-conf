{
  inputs,
  lib,
  pkgs,
  secureboot,
  stable,
  ...
}:
let
  inherit (lib) optionals;
in
{
  imports =
    optionals (stable && secureboot) [ inputs.lanzaboote-stable.nixosModules.lanzaboote ]
    ++ (optionals ((!stable) && secureboot) [ inputs.lanzaboote.nixosModules.lanzaboote ]);

  config =
    if secureboot then
      {
        environment.systemPackages = [
          # For debugging and troubleshooting Secure Boot.
          pkgs.sbctl
        ];

        # Lanzaboote currently replaces the systemd-boot module.
        # This setting is usually set to true in configuration.nix
        # generated at installation time. So we force it to false
        # for now.
        boot.loader.systemd-boot.enable = lib.mkForce false;

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      }
    else
      { };
}
