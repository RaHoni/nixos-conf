{ inputs, ... }:
let
  disk = "/dev/disk/by-id/ata-Hitachi_HTS723232A7A364_E3834263GENLTD";
in
{
  imports = [ inputs.disko.nixosModules.disko ];
  disko.devices = {
    disk.disk = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/permament" = {
                  mountpoint = "/permament";
                  mountOptions = [
                    "compress=zstd"
                  ];
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "32G";
                };
              };
            };
          };
        };
      };
    };
  };
}
