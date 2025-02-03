{ pkgs, lib, ... }: {
  services.hardware.bolt.enable = true;
  boot = {
    # Ensure module for external graphics is loaded
    initrd.kernelModules = [ "amdgpu" ];

    kernelParams = [ "amdgpu.pcie_gen_cap=0x40000" "udev.log_level=3" ];
  };
  # Use external graphics
  services.xserver = {
    videoDrivers = [ "amdgpu" "modesetting" ];
    # Load amdgpu first
    serverLayoutSection = ''
      Screen "Screen-amdgpu"
    '';
    # add section for amdgpu because it doesn't overwrite amdgpu[0] for some reason
    config = lib.mkAfter ''
      Section "Device"
        Identifier "Device-amdgpu"
        Driver     "amdgpu" 
        BusID      "PCI:06:00:0"
        Option     "AllowExternalGpus" "True"
        Option     "AllowEmptyInitialConfiguration"
      EndSection

      Section "Screen"
        Identifier "Screen-amdgpu"
        Device "Device-amdgpu"
      EndSection
    '';
  };
  hardware = {
    graphics = {
      enable = true;
      #driSupport = true;
      #driSupport32Bit = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd amdvlk ];
      extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    };
  };
}
