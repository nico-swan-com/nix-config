{ config, pkgs, configVars,  ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    dataDir = "/var/lib/postgresql";
    port = 5432;
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
