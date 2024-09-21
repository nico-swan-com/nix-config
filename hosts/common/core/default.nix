{ pkgs, ... }:
{
  # Set /etc/zshrc
  programs.zsh = {
    enable = true;
    # enableFzfCompletion = true;
    # enableFzfGit = true;
    # enableFzfHistory = true;
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    zsh
    vim
    nixpkgs-fmt
    nixfmt-classic
    sops
    just
    nil
    nixd

  ];
}
