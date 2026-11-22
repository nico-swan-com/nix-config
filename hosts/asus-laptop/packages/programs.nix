{ pkgs, ... }:
{

  # Antigravity IDE downloads its `agy` backend to ~/.gemini/bin/agy and spawns
  # it directly, and Paperclip's embedded PostgreSQL downloads prebuilt Linux
  # postgres binaries linked against /lib64/ld-linux-x86-64.so.2.
  # nix-ld provides a real dynamic loader and shared libraries for these binaries.
  # NOTE: log out/in (or reboot) after changing so NIX_LD/NIX_LD_LIBRARY_PATH
  # are present in the graphical and systemd user sessions.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      readline
      icu
      util-linux
      libxml2
      ncurses
      zstd
      curl
      krb5
    ];
  };

  # Set /etc/zshrc
  programs.zsh.enable = true;

}
