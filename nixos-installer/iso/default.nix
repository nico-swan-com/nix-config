{ pkgs, lib, config, configLib, cfg, ... }:
let

  pubKeys = lib.filesystem.listFilesRecursive (../../core/nixos/users/keys);
in {

  # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  services = {
    qemuGuest.enable = true;
    openssh = {
      ports = [ 22 ];
      settings.PermitRootLogin = lib.mkForce "yes";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "btrfs" "vfat" ];
  };

  networking = { hostName = "iso"; };

  users.users.nicoswan = {
    isNormalUser = true;
    description = "Nico Swan";
    home = "/home/nicoswan";
    password = "nixos";

    extraGroups = [ "wheel" "networkmanager" ];

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys =
      lib.lists.forEach pubKeys (key: builtins.readFile key);

    shell = pkgs.zsh; # default shell
  };

  # Proper root use required for borg and some other specific operations
  users.users.root = {
    # root's ssh keys are mainly used for remote deployment.
    openssh.authorizedKeys.keys =
      config.users.users.nicoswan.openssh.authorizedKeys.keys;
    password = "nixos";
  };

  programs.zsh.enable = true;
  programs.git.enable = true;
  environment.systemPackages = [ pkgs.just pkgs.rsync ];

  systemd = {
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    # gnome power settings to not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
