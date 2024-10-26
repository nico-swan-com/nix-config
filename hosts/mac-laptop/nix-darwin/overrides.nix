{lib, ...}:
{

  nix.linux-builder = {
    enable = lib.mkForce true;
    ephemeral = true;
  };

  nix = {
    settings = {
      # Necessary for using flakes on this system.
      extra-platforms = lib.mkForce [ "aarch64-linux" "x86_64-darwin" "aarch64-darwin" "x86_64-linux"];
      };
  };

}