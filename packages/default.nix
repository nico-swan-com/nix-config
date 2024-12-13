{ pkgs, ... }: {
  read-aloud = pkgs.callPackage ./cygnus-labs/read-aloud/read-aloud.nix { };
  ghost-cli = pkgs.callPackage ./ghost-blog/ghost-cli.yarn.nix { };
}
