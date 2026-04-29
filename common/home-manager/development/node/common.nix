{ pkgs, ... }:
{
  home.packages = [
    pkgs.unstable."npm-check-updates"
  ];
}
