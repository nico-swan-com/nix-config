final: prev:
{
  read-aloud = prev.callPackage ./custom/read-aloud/read-aloud.nix { };
  kindlegen = prev.callPackage ./kindlegen/kindlegen.nix { };
}
