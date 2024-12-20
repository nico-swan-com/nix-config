{ lib, ... }: {
  virtualisation.oci-containers.containers."appflowy-cloud-appflowy_worker" = {
    image = "localhost/appflowyinc/appflowy_worker:latest";
    environment = {
      "APPFLOWY_ENVIRONMENT" = "production";
      "APPFLOWY_MAILER_SMTP_EMAIL" = "notify@appflowy.io";
      "APPFLOWY_MAILER_SMTP_HOST" = "smtp.gmail.com";
      "APPFLOWY_MAILER_SMTP_PASSWORD" = "email_sender_password";
      "APPFLOWY_MAILER_SMTP_PORT" = "465";
      "APPFLOWY_MAILER_SMTP_USERNAME" = "notify@appflowy.io";
      "APPFLOWY_S3_ACCESS_KEY" = "minioadmin";
      "APPFLOWY_S3_BUCKET" = "appflowy";
      "APPFLOWY_S3_MINIO_URL" = "http://localhost:9000";
      "APPFLOWY_S3_REGION" = "us-east-1";
      "APPFLOWY_S3_SECRET_KEY" = "minioadmin";
      "APPFLOWY_S3_USE_MINIO" = "true";
      "APPFLOWY_WORKER_DATABASE_URL" =
        "postgres://postgres:password@localhost:5432/postgres";
      "APPFLOWY_WORKER_ENVIRONMENT" = "production";
      "APPFLOWY_WORKER_IMPORT_TICK_INTERVAL" = "30";
      "APPFLOWY_WORKER_REDIS_URL" = "redis://redis:6379";
      "RUST_LOG" = "info";
    };
    log-driver = "journald";
    extraOptions =
      [ "--network-alias=appflowy_worker" "--network=appflowy-cloud_default" ];
  };
  systemd.services."podman-appflowy-cloud-appflowy_worker" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [ "podman-network-appflowy-cloud_default.service" ];
    requires = [ "podman-network-appflowy-cloud_default.service" ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };

}
