# This file defines overlays/custom modifications to upstream packages
#
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: {
    read-aloud = final.callPackage ../modules/cygnus-labs/read-aloud/read-aloud.nix { };
  };
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Workaround for noto-fonts-subset build failure (cp: missing destination file operand).
    # Upstream derivation can fail when the copy step has no source files.
    # Replace with a minimal output so fonts.conf and dependent packages build.
    # Remove this override when nixpkgs fixes the derivation.
    noto-fonts-subset = prev.runCommand "noto-fonts-subset" { } ''
      mkdir -p $out/share/fonts/noto
      touch $out/share/fonts/noto/.keep
    '';
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "beekeeper-studio-5.3.4"  # Electron 31 is EOL, but package is still useful
        ];
      };
    };
  };

}
