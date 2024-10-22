{ pkgs, config, lib, inputs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  vmbfeqcyHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/vmbfeqcy/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (../../core/nixos/users/keys);
in
{
  sops = {
    secrets = {
      "users/vmbfeqcy/password".neededForUsers = true;
    };
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
    packages = with pkgs; [ ];
  };
}
