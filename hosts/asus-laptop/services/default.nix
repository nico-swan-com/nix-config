{ pkgs, ... }: {
  imports = [
    # Podman + dockerCompat for OCI apps (Paperclip, etc.)
    ../../../common/nixos/services/virtualisation
  ];

  services.onedrive = {
    enable = true;
    package = pkgs.unstable.onedrive;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      # Set to false after adding your other laptop's public key to core/nixos/users/keys/
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };
}
