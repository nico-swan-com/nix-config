{ pkgs, cfg, ... }:
{
  imports = [
    ./programs.nix
    ../../../modules/cygnus-labs/read-aloud
  ];

  gnome-read-aloud = {
    enable = true;
    user = cfg.username;
    #model-voice = "/home/nicoswan/Downloads/en_GB-alan-medium.onnx";
  };

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    vim
    xclip
    xsel
    piper-tts


    # Kubernetes tools
    kubectl
    kompose
    k9s
  ];
}
