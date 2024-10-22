{ pkgs, ... }: {
  # Desktop applications
  home.packages = with pkgs; [
    # GNOME Extentions
    gnome.gnome-shell-extensions
  ];
}
