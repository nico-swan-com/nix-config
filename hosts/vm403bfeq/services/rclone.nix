{ config, pkgs, ... }: {
  sops = {
    secrets = {
      "servers/cygnus-labs/services/google/vm403bfeq-service-account.json" =
        { };
    };
  };

  environment.systemPackages = [ pkgs.unstable.rclone ];
  environment.etc."rclone-google-drive.conf".text = ''
    [google-drive]
    type = drive
    scope = drive
    service_account_file = ${
      config.sops.secrets."servers/cygnus-labs/services/google/vm403bfeq-service-account.json".path
    }
  '';

  environment.etc."rclone-google-drive-shared.conf".text = ''
    [google-drive-shared]
    type = drive
    scope = drive
    service_account_file = ${
      config.sops.secrets."servers/cygnus-labs/services/google/vm403bfeq-service-account.json".path
    }
    shared_with_me = true


  '';

  #    [crypt]
  #    type = crypt
  #    remote = google-drive:data/backup
  #    filename_encryption = standard
  #    directory_name_encryption = true
  #    password = X
  #    password2 = X 
  #root_folder_id=1ROYnr5dK4TQFMdTV4_Dy0jgdMSHZOnl_
  #  impersonate=vm403bfeq@gmail.com
  #impersonate=vm403dfeq@gmail.com

  fileSystems."/mnt/google-drive" = {
    device = "google-drive:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-google-drive.conf"
    ];
  };

  fileSystems."/mnt/google-drive-shared" = {
    device = "google-drive-shared:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-google-drive-shared.conf"
    ];
  };
}
