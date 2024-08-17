{ pkgs, ... }:
{
  read-aloud = pkgs.callPackage ../modules/cygnus-labs/read-aloud/read-aloud.nix { };
  kindlegen = pkgs.callPackage ./kindlegen/kindlegen.nix { };
}
