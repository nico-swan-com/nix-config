{ pkgs, cfg, ... }: {
  imports = [
    #./ai.nix
    ../../../modules/cygnus-labs/read-aloud
  ];

  gnome-read-aloud = {
    enable = true;
    user = cfg.username;
    #model-voice = "/home/nicoswan/Downloads/en_GB-alan-medium.onnx";
  };

  environment.systemPackages = with pkgs; [
    qemu
    lima
    oci-cli
    #atac
    termshark
    portal
    sshs
    nixpacks
  ];
}
