{
  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 3;
    copyKernels = false;
    fsIdentifier = "label";
  };
}
