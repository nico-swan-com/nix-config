{ pkgs, ... }: {

  # Kubernetes UI
  home.packages = with pkgs; [
    lens
  ];
}
