{ pkgs, ... }: {

  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  services.sonarr = {
    enable = true;
    package = pkgs.unstable.sonarr;
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
