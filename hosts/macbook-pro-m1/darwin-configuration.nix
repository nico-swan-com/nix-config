{ config, pkgs, configVars, ... }:
{
  imports = [
    # Core must have system installations
    ../common/core
    ./macos-settings.nix

    # Services
    #../common/optional/databases/postgressql.nix

  ];

  # List system packages only for MacOS 
  environment.systemPackages = with pkgs; [
    terminal-notifier # send notification from the terminal
  ];

  # Set /etc/zshrc
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = {
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
      extra-platforms = [ "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      extra-trusted-users = [ "@admin" "@localhost" ];

      # Add needed system-features to the nix daemon
      # Starting with Nix 2.19, this will be automatic
      system-features = [
        "nixos-test"
        "apple-virt"
      ];
    };

    # Run the linux-builder as a background service
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };

    # Automatic garbage collection to remove unused packages
    gc = {
      automatic = true;
      #dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };



  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Users
  users.users = import ../common/users { inherit pkgs config configVars; };

  # Locale
  time.timeZone = configVars.timezone;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;



}
