{ pkgs, cfg, ... }: {
  imports = [ ./ai.nix ../../../modules/cygnus-labs/read-aloud ];

  gnome-read-aloud = {
    enable = true;
    user = cfg.username;
    model-voice =
      "/home/nicoswan/.local/share/read-aloud/voices/en_US-joe-medium.onnx";
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
    # for playwright
    glib
    gobject-introspection
    nspr
    nss
    dbus
    atk
    atkmm
    cups
    expat
    libxcb
    libxkbcommon
    at-spi2-core
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    mesa
    cairo
    pango
    udev
    alsa-lib
    gnumake
    gitlab-ci-ls

    minio-client

    # read-aloud extention
    xclip
    piper-tts
    alsa-utils
    glib

    fuse3
    sqlite
  ];
}
