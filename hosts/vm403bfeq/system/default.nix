{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./boot-loader.nix
    ./networking.nix
    ./nfs-server.nix
    ./nfs-client.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "no";
  };

  # Quemu guest agent
  services.qemuGuest.enable = true;

  # Required for remote vscode
  # https://nixos.wiki/wiki/Visual_Studio_Code
  programs.nix-ld.enable = true;

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  system.autoupgrade = {
    flake = inputs.self.outPath;
    #flake = "/root/.config/nix-config#vm403bfeq";
    flags = [ "-L" ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}
