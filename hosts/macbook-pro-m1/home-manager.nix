{ pkgs, configVars, ... }:

{
  imports = [
    # Setup users 
    # See the var/default.nix for the default configured users
    ../../home/users/Nico.Swan/macbook-pro-m1.nix


    # All user manditory configuration and packages
    ../../home/common/core

    # Optional packages and configiration for this host
    ../../home/common/optional/sops.nix
    ../../home/common/optional/desktop/fonts.nix
    ../../home/common/optional/development/google-cloud-sdk.nix

  ];

  home.username = configVars.username;
  home.homeDirectory = "/Users/${configVars.username}";
  home.stateVersion = configVars.stateVersion;

}
