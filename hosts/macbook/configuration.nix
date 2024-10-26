{ pkgs, inputs, lib, cfg, ... }:
{

  imports = [
    ./nix-darwin/overrides.nix
    ./nix-darwin/homebrew-packages.nix
    ./nix-darwin/macos-settings.nix
  ];

  # The default Nix build user ID range has been adjusted for
  # compatibility with macOS Sequoia 15. Your _nixbld1 user currently has
  # UID 352 rather than the new default of 351.
  ids.uids.nixbld = 351;

  # Install extra systemPackages
  environment.systemPackages = with pkgs; [
    qemu
  ] ++ (with pkgs.unstable; [
     #process-compose
     # openapi-tui # seems to not work with files
  ]);

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

}

