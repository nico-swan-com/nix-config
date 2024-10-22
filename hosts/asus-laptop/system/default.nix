{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot-loader.nix
    ./xserver.nix
    ./sound.nix
    ./networking.nix
    ./gnome-desktop.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
