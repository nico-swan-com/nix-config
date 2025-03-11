{ pkgs, ... }: {

  system.activationScripts.ombidatalink.text = ''
    mkdir -p /data/media
    ln -sfn "/mnt/media_storage/Media/Ombi" "/data/media/ombi"
    chown -R media:media /data/media
  '';

  services.ombi = {
    enable = true;
    package = pkgs.unstable.ombi;
    user = "media";
    group = "media";
    dataDir = "/data/media/ombi";
    openFirewall = true;
  };

}
