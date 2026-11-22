{

  # Antigravity IDE downloads its `agy` backend to ~/.gemini/bin/agy and spawns
  # it directly. That binary is linked against /lib64/ld-linux-x86-64.so.2,
  # which on NixOS is a stub that exits 127. nix-ld provides a real dynamic
  # loader for unpatched binaries like this one.
  # NOTE: log out/in (or reboot) after enabling so NIX_LD/NIX_LD_LIBRARY_PATH
  # are present in the graphical session.
  programs.nix-ld.enable = true;

  # Set /etc/zshrc
  programs.zsh.enable = true;

}
