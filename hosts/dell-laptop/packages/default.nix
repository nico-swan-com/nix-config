{ pkgs,configVars, ... }:
{
  imports = [
    ./programs.nix
    #./ai.nix
    ../../../modules/read-aloud/read-aloud.nix
  ];

  gnome-read-aloud = {
     enable = true;
     user = configVars.username;
  };

  environment.systemPackages = with pkgs; [
    vim

    epson-escpr2
    epson-escpr

    # Kubernetes tools
    kubectl
    kompose
    k9s
  ];
}
