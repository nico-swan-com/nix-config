{ pkgs, config, ... }: {
  sops = { secrets = { "servers/cygnus-labs/restic/passwordFile" = { }; }; };

  environment.systemPackages = with pkgs; [ restic ];
  system.activationScripts."restic-prepare-repo-dirs".text = ''
    mkdir -p /mnt/home/media/backup/cygnus-labs/postgres
  '';
  services.restic = {
    server = {
      enable = true;
      extraFlags = [ "--no-auth" ];
    };
    backups = {
      postgress-backup-home-nfs = {
        initialize = true;
        passwordFile =
          "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
        paths = [ "/data/postgres/backup" ];
        repository = "/mnt/home/media/backup/cygnus-labs/postgres";
      };
    };
  };
}
