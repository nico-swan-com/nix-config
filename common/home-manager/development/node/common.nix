{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    npm-check-updates
  ];
}
