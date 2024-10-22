{ config, pkgs, cfg, ... }:
let
  dataDir = "/data/postgres/16";
  #gitlabPassword = "$(cat ${config.sops.secrets."servers/cygnus-labs/gitlab/dbPassword".path})";
in
{
  # sops = {
  #   secrets = {
  #     "servers/cygnus-labs/gitlab/dbPassword" = {};
  #   };
  # };

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
    ensureDatabases = [ "${cfg.username}" "test" "gitlab" ];
    ensureUsers = [
      {
        name = cfg.username;
        ensureDBOwnership = true;
        ensureClauses = {
          superuser = true;
          replication = true;
          login = true;
          #          inherit = true;
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
    ];
    extraPlugins = ps: with ps; [
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
      pg_net
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
    #initialScript = pkgs.writeText "init-sql-script" ''
    #  alter user  with password 'password';
    #'';
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


  services.postgresqlBackup = {
    enable = true;
    location = "/data/postgres/backup";
    backupAll = true;
  };
}
