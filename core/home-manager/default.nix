{ pkgs, cfg, ... }:
{

    imports = [
      ../common/home-packages.nix
    ];
  
    home.stateVersion = "24.05";

    fonts.fontconfig.enable = true;

    programs = {
      home-manager.enable = true;

      nicoswan = {
        zsh.enable = true;
        starship.enable = true;
      };

      # Git configuration
      git = {
        enable = true;
        userName = cfg.fullname;
        userEmail = cfg.email;
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;   
      };
    };
}
