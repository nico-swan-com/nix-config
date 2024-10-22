{
  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/data/media/radarr";
    user = "media";
    group = "media";
  };

  system.activationScripts.radarrdatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/Radarr" /data/media/radarr
    chown -R media:media /data/media
  '';
}
