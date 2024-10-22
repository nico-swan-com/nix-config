{ pkgs, ... }:
{
  read-aloud = pkgs.callPackage ./cygnus-labs/read-aloud/read-aloud.nix { };
}
