{ pkgs, inputs, config, ... }:
{

  #Import your own custom modules
  imports = [
    # Core
    ./home-manager/sops.nix # Setup up user level secrets
    ./home-manager/dot-npmrc.nix # Setup your developer .npmrc file

    # Optional Desktop Applications
    ./home-manager/desktop

    # Optional Terminal Applucations
    ./home-manager/lunarvim.nix # Terminal IDE based on neovim

    ./home-manager/custom-zsh-functions.nix # Custom zsh functions

    # BCB
    ./home-manager/bcb/default.nix

    #./modules/bcb/services/per-branch.nix
    ./modules/docker/docker-compose-example.nix

  ];

  services.docker-compose.example.enable = false;

  fonts.fontconfig.enable = true;

  # services.bcb.per-branch = {
  #   enable = true;
  #   name = "admin-api";
  #   branch = "sandbox";
  # };

  # Install addition packages via home manager
  home.packages = with pkgs.unstable; [
     process-compose
     # openapi-tui # seems to not work with files
  ] ++ (with pkgs; [
    sops

    # Utils
    lazydocker # Terninal UI for docker
    podman-tui # Podman terminal UI
    portal # Copy files
    sshs # SSH session manager

    # Productivity tools
    slides
    visidata
    glow # Terminal marckdown viewer

    # Development
    devenv # development environments
    git-extras
    nodejs_20 # Node 20 (setup as default)
    nodePackages.npm-check-updates # ncu updater for node packages in projects
    atac # Postman for the terminal

    # Fonts
    fira-code-nerdfont # Font installation
    noto-fonts
    meslo-lgs-nf

    #ceryx
    # Network security
    termshark

    # AI
    oterm

  ]);

   programs.nnn.bookmarks = {
     D = "~/Documents";
     d = "~/Developer/src";
     h = "~/";
   };

  programs.zsh = {
    shellAliases = {
      dev = "cd ~/Developer/src";
      nstart = "nest start --watch";
      dstart = "nest start --watch --debug";
      ngs = "ng serve";
    };

    sessionVariables = {
      NVM_DIR = "$HOME/.nvm";
      BCB_SERVICES_SERVICE_ACCOUNT = config.sops.secrets."bcb/services/service-account.json".path;
    };

    # This is added for when you have nvm install via homebrew
    # Also the manual install for iterm2
    initExtra = ''
          export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

          [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
          [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

          test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"

          klogs-sandbox () {
            pod = "$(kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox get po -o wide|tail -n+2|fzf -n1 --reverse --tac --preview='kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox -n sandbox logs --tail=20 --all-containers=true {1} |jq' --preview-window=down:50%:hidden --bind=ctrl-p:toggle-preview --header="^P: Preview Logs "|awk '{print $1}' | jq)"
              if [[ -n $pod ]];
              then
                kubectl --context gke_bcb-group-sandbox_europe-west2_sandbox logs --all-containers = true $pod
              fi
          }
    '';
  };






  launchd = let
    dockerStartScript = pkgs.writeScript "dockerStartScript" ''

      echo "PATH=$PATH"
      ${pkgs.docker-compose}/bin/docker-compose -f ${pkgs.ceryx}/docker-compose.yml up
    '';
  in{
      enable = true;
      agents = {
        "ceryx" = {
          enable = false;
          config = {
            ProgramArguments = [
              "${pkgs.bash}/bin/bash"
              "-l"
              "-c"
              "${dockerStartScript}"
            ];
            UserName = "Nico.Swan";
            Label = "ceryx.docker.service";
            StandardErrorPath = "/Users/Nico.Swan/Library/Logs/ceryx-docker.stderr.log";
            StandardOutPath = "/Users/Nico.Swan/Library/Logs/ceryx-docker.stdout.log";
            RunAtLoad = true;
            KeepAlive = true;
            EnableTransactions = false;
            EnvironmentVariables = {
              PATH = "${pkgs.docker}/bin:${pkgs.docker-compose}/bin";
            };
          };
        };
      };
    };

}
