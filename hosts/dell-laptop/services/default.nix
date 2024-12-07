{ pkgs, ... }: {
  imports = [
    # Core services
    ../../../common/nixos/services/virtualisation
    #./hydra.nix  # CI tool 
    #./kubernetes.nix # Container management
    #./nextcloud # Own home Cloud 
  ];

  services.onedrive = {
    enable = true;
    package = pkgs.unstable.onedrive;
  };
}
