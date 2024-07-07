{ pkgs, ... }:
{

  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    nodejs_20
  ];
}
