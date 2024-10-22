{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodePackages.npm-check-updates
  ];
}
