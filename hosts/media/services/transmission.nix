{


  system.activationScripts.transmissiondatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/transmission" "/data/media/transmission"
    chown -R media:media /data/media
  '';

  services.transmission = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
    home = "/data/media/transmission";
  };

}
