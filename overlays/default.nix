# This file defines overlays/custom modifications to upstream packages
#
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory.
  # noto-fonts-subset override must be in the first overlay so it's in the final pkgs.
  additions = final: prev: {
    read-aloud = final.callPackage ../modules/cygnus-labs/read-aloud/read-aloud.nix { };
    # Workaround: noto-fonts-subset build fails in nixpkgs (cp: missing destination).
    # Stub so fonts.conf and dependents build. Remove when nixpkgs fixes the derivation.
    noto-fonts-subset = prev.runCommand "noto-fonts-subset-workaround" { } ''
      mkdir -p $out/share/fonts/noto
      touch $out/share/fonts/noto/.keep
    '';
  };
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: _prev: { };

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
