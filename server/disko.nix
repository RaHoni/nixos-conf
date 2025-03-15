{ inputs, ... }:
let
  disk = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_M.2_500GB_S5GCNJ0N718624R";
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
                "/" = {
                  mountpoint = "/btrfs";
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/tmp" = {
                  mountpoint = "/tmp";
                };
                "/cache" = {
                  mountpoint = "/var/cache";
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
