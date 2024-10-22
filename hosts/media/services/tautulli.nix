{

  system.activationScripts.tautulliatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/tautulli" "/data/media/tautulli"
    chown -R media:media /data/media
  '';

  services.tautulli = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
    dataDir = "/data/media/tautulli";
  };

}
