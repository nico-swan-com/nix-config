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
  modifications = final: prev:
    {
      # example = prev.example.overrideAttrs (oldAttrs: let ... in {
      # ...
      # });
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
