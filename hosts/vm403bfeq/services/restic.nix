{ pkgs, config, ... }:
let
  passwordFile =
    "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
in {
  sops = { secrets = { "servers/cygnus-labs/restic/passwordFile" = { }; }; };

  environment.systemPackages = with pkgs; [ restic ];
  #  system.activationScripts."restic-prepare-repo-dirs".text = ''
  #    mkdir -p /mnt/home/backup/cygnus-labs/postgres
  #  '';
  services.restic = {
    server = {
      enable = true;
      extraFlags = [ "--no-auth" "--prometheus-no-auth" ];
    };
    #    backups = {
    #
    #      gitlab-backup-home-nfs = {
    #        initialize = true;
    #        passwordFile = "${passwordFile}";
    #        paths = [ "/var/gitlab/state/backup" ];
    #        repository = "/mnt/home/backup/cygnus-labs/gitlab";
    #      };
    #
    #      gitlab-backup-google-drive = {
    #        initialize = true;
    #        passwordFile = "${passwordFile}";
    #        paths = [ "/var/gitlab/state/backup" ];
    #        repository = "rclone:encrypted-google-drive-backup:/restic-repo/gitlab";
    #      };
    #
    #
    #    };
  };
}
