{ pkgs, ... }:
{

  home.packages = [
    ../../../../packages/custom/read-aloud
    { inherit pkgs; }
  ];
}
