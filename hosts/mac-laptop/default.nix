{ pkgs, ... }:
{
  ceryx = pkgs.callPackage ./ceryx/default.nix { };
}
