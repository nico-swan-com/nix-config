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
    xorg.libxcb
    libxkbcommon
    at-spi2-core
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
    cairo
    pango
    udev
    alsa-lib
  ];
}
