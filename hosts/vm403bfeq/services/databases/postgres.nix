{ config, pkgs, cfg, ... }:
let
  dataDir = "/data/postgres/16";
  gitlabPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/gitlab/databasePasswordFile".path
    })";
  adminPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/postgres/users/admin/password".path
    })";
  keycloakUsername = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/keycloak/dbUsername".path
    })";
  keycloakPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/keycloak/dbPassword".path
    })";
  penpotPassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/penpot/dbPassword".path
    })";
  solidtimePassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/solidtime/dbPassword".path
    })";
  resticPasswordFile =
    "${config.sops.secrets."servers/cygnus-labs/restic/passwordFile".path}";
  affinePassword = "$(cat ${
      config.sops.secrets."servers/cygnus-labs/affine/dbPassword".path
    })";
in {
  sops = {
    secrets = {
      "servers/cygnus-labs/restic/passwordFile" = { };
      "servers/cygnus-labs/gitlab/databasePasswordFile" = { };
      "servers/cygnus-labs/postgres/users/admin/password" = { };
      "servers/cygnus-labs/keycloak/dbUsername" = { };
      "servers/cygnus-labs/keycloak/dbPassword" = { };
      "servers/cygnus-labs/penpot/dbPassword" = { };
      "servers/cygnus-labs/solidtime/dbPassword" = { };
      "servers/cygnus-labs/affine/dbPassword" = { };
    };
  };

  system.activationScripts.postgresData.text = ''
    mkdir -p ${dataDir}
    chown -R postgres ${dataDir}
  '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    dataDir = dataDir;
    settings = {
      port = 5432;
      listen_addresses = "*";
    };
    ensureDatabases =
      [ "${cfg.username}" "keycloak" "gitlab" "penpot" "docmost" "solidtime" "affine" ];
    ensureUsers = [
      {
        name = cfg.username;
        ensureDBOwnership = true;
        ensureClauses = {
          superuser = true;
          replication = true;
          login = true;
          createrole = true;
          createdb = true;
          bypassrls = true;
        };
      }
      {
        name = "gitlab";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
      {
        name = "penpot";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
      {
        name = "docmost";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
      {
        name = "solidtime";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
      {
        name = "affine";
        ensureDBOwnership = true;
        ensureClauses = {
          createrole = true;
          createdb = true;
        };
      }
    ];
    extensions = ps:
      with ps; [
        rum
        timescaledb
        pgroonga
        wal2json
        pg_repack
        pg_safeupdate
        plpgsql_check
        pgjwt
        pgaudit
        postgis
        pgrouting
        pgtap
        pg_cron
        pgsql-http
        #pg_net
        pgsodium
        pgvector
        hypopg
        plv8
        # Missing supabase plugins
        #    index_advisor
        #    pg_tle
        #    wrappers
        #    supautils
        #    pg_graphql
        #    pg_stat_monitor
        #    pg_jsonschema
        #    pg_hashids
        #    pg_plan_filter
        #    pg_backtrace
        #    vault

      ];
    initialScript = pkgs.writeText "init-sql-script" ''
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      alter user ${cfg.username} with password '${adminPassword}';
      alter user gitlab with password '${gitlabPassword}';
      alter user ${keycloakUsername} with password '${keycloakPassword}';
      alter user penpot with password '${penpotPassword}';
      alter user solidtime with password '${solidtimePassword}';
      alter user affine with password '${affinePassword}';
    '';
    authentication = pkgs.lib.mkOverride 10 ''
      #type    database DBuser  origin-address auth-methoda
      local    all      all                    trust
      # ipv4
      host     all      all     127.0.0.1/32   trust
      host     all      all     0.0.0.0/0      md5
      # ipv6
      host     all      all     ::1/128        trust
      host     all      all     ::1/0          md5
    '';
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root                    postgres
      superuser_map      postgres                postgres
      superuser_map      ${cfg.username}  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';

  };

  # system.activationScripts.postActivation = {
  #     enable = true;
  #     text = '' ${createUserScript} '';
  # };

  services.postgresqlBackup = {
    enable = true;
    location = "/data/postgres/backup";
    backupAll = true;
  };

  services.restic = {
    backups = {
      postgres-backup-home-nfs = {
        initialize = true;
        passwordFile = "${resticPasswordFile}";
        paths = [ "/data/postgres/backup" ];
        repository = "/mnt/home/ntfs_drive/backup/cygnus-labs/postgres";
      };
      postgres-backup-google-drive = {
        initialize = true;
        passwordFile = "${resticPasswordFile}";
        paths = [ "/data/postgres/backup" ];
        repository =
          "rclone:encrypted-google-drive-backup:/restic-repo/postgres";
      };
    };
  };
}