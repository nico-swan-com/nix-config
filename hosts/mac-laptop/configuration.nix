{ pkgs, inputs, lib, cfg, ... }:
{

  imports = [
    ./nix-darwin/overrides.nix
    ./nix-darwin/homebrew-packages.nix
    ./nix-darwin/macos-settings.nix


    #Custom modules
    ./nix-darwin/custom-modules/tools/gefyra
    ./modules/databases
  ];

  # The default Nix build user ID range has been adjusted for
  # compatibility with macOS Sequoia 15. Your _nixbld1 user currently has
  # UID 352 rather than the new default of 351.
  ids.uids.nixbld = 351;

  # Install extra systemPackages
  environment.systemPackages = with pkgs; [
    qemu
  ] ++ (with pkgs.unstable; [
     #process-compose
     # openapi-tui # seems to not work with files
  ]);

  # # Install extra systemPackages
  # environment.systemPackages = with pkgs; [
  #    inputs.nixpkgs-unstable.packages.${pkgs.system}.openapi-tui
  # ];

  programs.gefyra.enable = true;

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  # Install nginx proxy configured with vhost directrectory to add additioanl host configs
  # This is populated by the bcb host-updater with all sandbox sservices
  services.nginx = {
    enable = true;
    vhostDirectories = [ "/Users/${cfg.username}/.config/bcb/nginx/vhosts" ];
  };

  # This update you host file and generate the nginx vhosts based on the
  # Home-manager service bcb.port-forward
  services.bcb.host-updater = {
    enable = true;
    username = cfg.username;
    userHome = "/Users/${cfg.username}";
  };

  # Create a postgres database for the user
  services.databases.postgres = {
    enable = false;
    port = 5100;
    username = cfg.username;
    dataDir = "/tmp/data/postgres";
    password = "password"; # This must be applyed with a sops secret but the deffault password for your user is password
  };

  # services.launchd.daemons.docker-compose = {
  #   enable = true;
  #   program = "${pkgs.docker-compose}/bin/docker-compose";
  #   programArguments = [
  #     "-f"
  #     "${pkgs.ceryx}/docker-compose.yml"
  #     "up"
  #     "-d"
  #   ];
  #   keepAlive = true;
  #   runAtLoad = true;
  #   # workingDirectory = "/path/to/your/docker-compose";
  #   environmentVariables = {
  #     PATH = "${pkgs.docker}/bin:${pkgs.docker-compose}/bin";
  #   };
  # };
}

