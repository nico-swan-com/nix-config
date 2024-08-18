{ config, pkgs, configVars, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    dataDir = "/data/postgres/16";
    port = 5432;
    extraPlugins = ps: with ps; [
      rum
      timescaledb
      pgroonga
      wal2json
      pg_repack
      pg-safeupdate
      plpgsql-check
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
      vault
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
      
    ];
    # initialScript = pkgs.writeText "init-sql-script" ''
    #   alter user postgres with password 'password';
    # '';
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root                    postgres
      superuser_map      postgres                postgres
      superuser_map      ${configVars.username}  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';

  };
}
