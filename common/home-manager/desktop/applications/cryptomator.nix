{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    cryptomator
  ];
}

