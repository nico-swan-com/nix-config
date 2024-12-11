{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable;
    [ appflowy ]; # This is a desktop app need to install via docker
}
