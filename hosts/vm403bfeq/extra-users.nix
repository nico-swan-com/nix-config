{ pkgs, config, lib, inputs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  vmbfeqcyHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/vmbfeqcy/password".path;
  deployerHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/deployer/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (../../core/nixos/users/keys);
in
{
  sops = {
    secrets = {
      "users/vmbfeqcy/password".neededForUsers = true;
      "users/deployer/password".neededForUsers = true;
      "users/deployer/private-key" = {
        path = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/deployer/private-key".path;
      };
    };
  };

  users.groups.deployer = {
     members = ifTheyExist [
      "docker"
      "podman"
      "git"
    ];
  };
  

  users.users.vmbfeqcy = {
    isNormalUser = true;
    description = "Nico Swan";
    hashedPasswordFile = vmbfeqcyHashedPasswordFile;
    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "docker"
      "podman"
      "git"
      "networkmanager"
    ];
    shell = pkgs.zsh; # default shell
  };

  users.users.deployer = {
    isNormalUser = true;
    description = "Kubernetes Deployer";
    hashedPasswordFile = deployerHashedPasswordFile;
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVO4sSaq5GG3MHLCnYu3GfCO5e75RrpTnOmAXlBj6RO deployer"
    ];
    group = "deployer";
    shell = pkgs.zsh;
  };
}
