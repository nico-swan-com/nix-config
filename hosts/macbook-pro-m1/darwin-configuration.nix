{ pkgs, ... }:
{
  imports = [
    # Core must have system installations
    ../common/core
    ./system
  ];
  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
  ];

}
