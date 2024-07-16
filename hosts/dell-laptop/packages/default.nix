{ pkgs, ... }:
{
  imports = [
    ./programs.nix
    #./ai.nix
    #../../../modules/read-aloud/read-aloud.nix
  ];

  #services.read-aloud.enable = true;

  environment.systemPackages = with pkgs; [

    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    vim
    # xclip
    # xsel
    # piper-tts

    epson-escpr2
    epson-escpr

    # Kubernetes tools
    kubectl
    kompose
    k9s
  ];
}
