{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:

let
  smbpass =
    with config.users.users;
    pkgs.writeText "smbpass" ''
      raoul:${toString (raoul.uid - 1000)}:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:4A412408BDF3250B8527BDCC6598BCBC:[U          ]:LCT-64FB8379:
      sylvia:${toString (sylvia.uid - 1000)}:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:1B6553BF1C274D8917F5C1060DF900EC:[U          ]:LCT-64FC986B:
      christoph:${
        toString (christoph.uid - 1000)
      }:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:00339E26411CF8BFADA8361A497EBDFC:[U          ]:LCT-64FC9B9D:
      stella:${toString (stella.uid - 1000)}:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:55284D2147251A2DFFFEA32A50DB3787:[U          ]:LCT-64FC988F:
    '';
in
{
  networking.hostName = "smb";
  networking.nameservers = [
    "192.168.3.102"
    "192.168.2.1"
    "1.1.1.1"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    shares = {
      bilder = {
        path = "/mnt/data/bilder";
        browseable = "yes";
        "read only" = "no";
        "directory mask" = "0755";
        "create mask" = "0775";
      };
      hoerbuecher = {
        path = "/mnt/data/hoerbuecher";
        browseable = "yes";
        "read only" = "no";
        "directory mask" = "0755";
        "create mask" = "0775";

      };
      homeassistant = {
        path = "/mnt/data/homeassistant";
        browseable = "yes";
        "read only" = "no";
        "directory mask" = "0755";
        "create mask" = "0775";
      };

    };
  };
  users.users = {
    raoul = {
      uid = 1000;
      isNormalUser = true;
    };
    christoph = {
      uid = 1001;
      isNormalUser = true;
    };
    sylvia = {
      uid = 1002;
      isNormalUser = true;
    };
    stella = {
      uid = 1003;
      isNormalUser = true;
    };
  };

  system.activationScripts = {
    sambaUserSetup = {
      text = ''
        PATH=$PATH:${lib.strings.makeBinPath [ pkgs.samba ]}
        cp ${smbpass} smbpass
        pdbedit -i smbpasswd:smbpass -e tdbsam:/var/lib/samba/private/passdb.tdb   
        rm smbpass
      '';
      deps = [ ];
    };
  };

  system.stateVersion = "23.05";
}
