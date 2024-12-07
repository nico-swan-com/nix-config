{ pkgs, ... }: {
  imports = [
    ../common/system-packages.nix
  ];
  # List system packages for MacOS 
  environment.systemPackages = with pkgs; [
    # utils
    terminal-notifier # send notification from the terminal
    fswatch # watch file system events
  ];
}
