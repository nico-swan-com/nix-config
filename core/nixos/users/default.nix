{ pkgs, inputs, config, lib, cfg, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  userHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/${cfg.username}/password".path;
  rootHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/root/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (./keys);

  rootPassword =
    if (rootHashedPasswordFile != "") then {
      hashedPasswordFile = rootHashedPasswordFile;
    } else {
      password = "nixos";
    };

  # these are values we don't want to set if the environment is minimal. E.g. ISO or nixos-installer
  # isMinimal is true in the nixos-installer/flake.nix
  userPassword =
    if (userHashedPasswordFile != "") then {
      hashedPasswordFile = userHashedPasswordFile;
    } else {
      password = "nixos";
    };

  # these are values we don't want to set if the environment is minimal. E.g. ISO or nixos-installer
  # isMinimal is true in the nixos-installer/flake.nix
  fullUserConfig = lib.optionalAttrs (!(lib.hasAttr "isMinimal" cfg))
    {
      users.mutableUsers = false; # Required for password to be set via sops during system activation!
      users.users.${cfg.username} = {
        packages = [ pkgs.home-manager ];
      };

      # Import this user's personal/home configurations
      # BUG: This does not seem to work... with nico modules
      #home-manager.users.${cfg.username} = import (configLib.relativeToRoot "hosts/${cfg.hostname}/users/${cfg.username}/home-manager.nix");
    };
in
{
  config = lib.recursiveUpdate fullUserConfig
    #this is the second argument to recursiveUpdate
    {
      users.users.${cfg.username} = lib.recursiveUpdate userPassword {
        isNormalUser = true;
        description = cfg.fullname;
        home =
          if pkgs.stdenv.isLinux
          then "/home/${cfg.username}"
          else "/Users/${cfg.username}";

        extraGroups = [
          "wheel"
        ] ++ ifTheyExist [
          "audio"
          "video"
          "docker"
          "podman"
          "git"
          "networkmanager"
        ];

        # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
        openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

        shell = pkgs.zsh; # default shell
      };

      # Proper root use required for borg and some other specific operations
      users.users.root = lib.recursiveUpdate rootPassword {
        # root's ssh keys are mainly used for remote deployment.
        openssh.authorizedKeys.keys = config.users.users.${cfg.username}.openssh.authorizedKeys.keys;
      };

      # No matter what environment we are in we want these tools for root, and the user(s)
      programs.zsh.enable = true;
      programs.git.enable = true;
      environment.systemPackages = [
        pkgs.just
        pkgs.rsync
      ];
    };
}
