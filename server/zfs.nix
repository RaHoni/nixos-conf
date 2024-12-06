{ config, ... }:
{
  fileSystems = {
    "/var/lib/audiobookshelf/audiobooks" = {
      device = "MainZFS:subvol-209-disk-1";
      fsType = "zfs";
    };
    "/var/lib/audiobookshelf/ebooks" = {
      device = "MainZFS:subvol-209-disk-2";
      fsType = "zfs";
    };
    "/var/data" = {
      device = "MainZFS:subvol-210-disk-0";
      fsType = "zfs";
    };
    "/var/bacula" = {
      device = "MainZFS:subvol-210-disk-1";
      fsType = "zfs";
    };
    "/var/smb" = {
      device = "MainZFS:subvol-206-disk-0";
      fsType = "zfs";
    };
  };
}
