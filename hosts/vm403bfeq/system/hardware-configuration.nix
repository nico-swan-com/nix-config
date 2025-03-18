{ config, lib, pkgs, ... }: {

  #Hardware  
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
  ];
  boot.initrd.kernelModules =
    [ "nvme" "kvm-intel" "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.initrd.postDeviceCommands =
    lib.mkIf (!config.boot.initrd.systemd.enable) ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  #  fileSystems."/" = {
  #    device = "/dev/disk/by-label/ROOT";
  #    fsType = "ext4";
  #  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/ROOT";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 4 * 1024;
  }];

}
