# default.nix
final: prev:
{
  read-aloud = prev.callPackage ./read-aloud.nix { };
}
