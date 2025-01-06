{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems = {
    "/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "dev/vda16";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "dev/vda15";
      fsType = "vfat";
    };
  };
}
