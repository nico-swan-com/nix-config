{

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/data/media/sonarr";
    user = "media";
    group = "media";
  };

  system.activationScripts.sonarrdatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/Sonarr" /data/media/sonarr
    chown -R media:media /data/media
  '';
}
