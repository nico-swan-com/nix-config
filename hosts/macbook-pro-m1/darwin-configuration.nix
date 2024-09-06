{ pkgs, configVars, ... }:
{
  imports = [
    # Core must have system installations
    ../common/core
    ./system

    # BCB Services
    ./services/system/bcb

    #./modules/coredns.nix
    #./modules/kubernetes/k0s.nix

  ];
  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
    #open-interpreter # OpenAI's Code Interpreter in your terminal, running locally
    mprocs #TUI to start processes
    #coredns # DNS server
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.cloud_sql_proxy
      google-cloud-sdk.components.pubsub-emulator
      google-cloud-sdk.components.kubectl
    ])
  ];

   # Set /etc/zshrc
  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

}
