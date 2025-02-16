{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ./networking.nix
    ./nfs-server.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "no";
  };

  # Required for remote vscode
  # https://nixos.wiki/wiki/Visual_Studio_Code
  programs.nix-ld.enable = true;

}
