{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    nodePackages.npm-check-updates
  ];
}
