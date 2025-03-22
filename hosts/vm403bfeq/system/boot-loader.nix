{
  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    efiSupport = true;
    configurationLimit = 3;
    copyKernels = false;
    fsIdentifier = "label";

  };
}
