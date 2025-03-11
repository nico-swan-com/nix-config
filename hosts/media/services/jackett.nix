{ pkgs, ... }: {

  services.jackett = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.jackett;
    dataDir = "/data/media/jackett";
    user = "media";
    group = "media";
  };

  system.activationScripts.jackettdatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/jackett" /data/media/jackett
    chown -R media:media /data/media
  '';
}
