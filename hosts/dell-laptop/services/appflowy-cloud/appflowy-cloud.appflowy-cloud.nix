{ lib, ... }: {
  virtualisation.oci-containers.containers."appflowy-cloud-appflowy_cloud" = {
    image = "localhost/appflowyinc/appflowy_cloud:latest";
    environment = {
      "APPFLOWY_ACCESS_CONTROL" = "true";
      "APPFLOWY_AI_SERVER_HOST" = "localhost";
      "APPFLOWY_AI_SERVER_PORT" = "5001";
      "APPFLOWY_DATABASE_MAX_CONNECTIONS" = "40";
      "APPFLOWY_DATABASE_URL" =
        "postgres://postgres:password@localhost:5432/postgres";
      "APPFLOWY_ENVIRONMENT" = "production";
      "APPFLOWY_GOTRUE_ADMIN_EMAIL" = "admin@example.com";
      "APPFLOWY_GOTRUE_ADMIN_PASSWORD" = "password";
      "APPFLOWY_GOTRUE_BASE_URL" = "http://localhost:9999";
      "APPFLOWY_GOTRUE_EXT_URL" = "http://localhost:9999";
      "APPFLOWY_GOTRUE_JWT_EXP" = "7200";
      "APPFLOWY_GOTRUE_JWT_SECRET" = "hello456";
      "APPFLOWY_MAILER_SMTP_EMAIL" = "notify@appflowy.io";
      "APPFLOWY_MAILER_SMTP_HOST" = "smtp.gmail.com";
      "APPFLOWY_MAILER_SMTP_PASSWORD" = "email_sender_password";
      "APPFLOWY_MAILER_SMTP_PORT" = "465";
      "APPFLOWY_MAILER_SMTP_USERNAME" = "notify@appflowy.io";
      "APPFLOWY_REDIS_URI" = "appflowy";
      "APPFLOWY_S3_ACCESS_KEY" = "minioadmin";
      "APPFLOWY_S3_BUCKET" = "appflowy";
      "APPFLOWY_S3_CREATE_BUCKET" = "true";
      "APPFLOWY_S3_MINIO_URL" = "http://localhost:9000";
      "APPFLOWY_S3_REGION" = "us-east-1";
      "APPFLOWY_S3_SECRET_KEY" = "minioadmin";
      "APPFLOWY_S3_USE_MINIO" = "true";
      "RUST_LOG" = "info";
    };
    log-driver = "journald";
    extraOptions =
      [ "--network-alias=appflowy_cloud" "--network=appflowy-cloud_default" ];
  };

  systemd.services."podman-appflowy-cloud-appflowy_cloud" = {
    serviceConfig = { Restart = lib.mkOverride 90 "on-failure"; };
    after = [ "podman-network-appflowy-cloud_default.service" ];
    requires = [ "podman-network-appflowy-cloud_default.service" ];
    partOf = [ "podman-compose-appflowy-cloud-root.target" ];
    wantedBy = [ "podman-compose-appflowy-cloud-root.target" ];
  };
}
