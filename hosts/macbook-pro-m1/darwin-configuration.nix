{ pkgs, ... }:
{
  imports = [
    # Core must have system installations
    ../common/core
    ./system
    ./services/coredns.nix
    ./modules/coredns.nix
  ];
  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
    open-interpreter # OpenAI's Code Interpreter in your terminal, running locally
    mprocs #TUI to start processes
    coredns # DNS server
  ];

}
