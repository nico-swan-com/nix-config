{ pkgs, config, ... }: {
  sops = { secrets = { "servers/cygnus-labs/restic/passwordFile" = { }; }; };

  environment.systemPackages = with pkgs; [ restic ];
  #  system.activationScripts."restic-prepare-repo-dirs".text = ''
  #    mkdir -p /mnt/home/backup/cygnus-labs/postgres
  #  '';
  services.restic = {
    server = {
      enable = true;
      extraFlags = [ "--no-auth" ];
    };
    backups = {
      postgres-backup-home-nfs = {
        initialize = true;
        passwordFile =
          "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
        paths = [ "/data/postgres/backup" ];
        repository = "/mnt/home/backup/cygnus-labs/postgres";
      };
      postgres-backup-google-drive = {
        initialize = true;
        passwordFile =
          "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
        paths = [ "/var/gitlab/state/backup" ];
        repository =
          "rclone:encrypted-google-drive-shared:/restic-repo/postgres";
      };

      gitlab-backup-home-nfs = {
        initialize = true;
        passwordFile =
          "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
        paths = [ "/var/gitlab/state/backup" ];
        repository = "/mnt/home/backup/cygnus-labs/gitlab";
      };
      gitlab-backup-google-drive = {
        initialize = true;
        passwordFile =
          "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
        paths = [ "/var/gitlab/state/backup" ];
        repository = "rclone:encrypted-google-drive-shared:/restic-repo/gitlab";
      };
    };
  };
}