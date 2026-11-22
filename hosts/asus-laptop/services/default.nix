{ pkgs, ... }: {
  imports = [
    # Podman + dockerCompat for OCI apps (Paperclip, etc.)
    ../../../common/nixos/services/virtualisation
  ];

  services.onedrive = {
    enable = true;
    package = pkgs.unstable.onedrive;
  };
}
