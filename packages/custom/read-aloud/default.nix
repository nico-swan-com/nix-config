# default.nix
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
{
  cygnus-labs.read-aloud = pkgs.callPackage ./read-aloud.nix { };
}
