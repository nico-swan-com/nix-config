{ pkgs, ... }:
{
  imports = [
    ../../../common/nixos/services/virtualisation/default.nix
  ];

  services.onedrive = {
    enable = true;
    package = pkgs.unstable.onedrive;
  };
}
