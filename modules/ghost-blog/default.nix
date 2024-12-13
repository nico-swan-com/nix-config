{ options, lib, config, pkgs, ... }:
let
  # domain for the Ghost blog
  serverName = "blog.example.net";
  # port on which the Ghost service runs
  port = 1357;
  # user used to run the Ghost service
  userName = builtins.replaceStrings [ "." ] [ "_" ] serverName;
  # database type
  dbType = "postgres";
  # MySQL database used by Ghost
  dbName = userName;
  # MySQL user used by Ghost
  dbUser = userName;
  # directory used to save the blog content
  dataDir = "/var/lib/${userName}";
  # Ghost package we created in the section above
  ghost = pkgs.ghost;
  # script that sets up the Ghost content directory
  setupScript = pkgs.writeScript "${serverName}-setup.sh" ''





    #! ${pkgs.stdenv.shell} -e
    chmod g+s "${dataDir}"
    [[ ! -d "${dataDir}/content" ]] && cp -r "${ghost}/content" "${dataDir}/content"
    chown -R "${userName}":"${userName}" "${dataDir}/content"
    chmod -R +w "${dataDir}/content"
    ln -f -s "/etc/${serverName}.json" "${dataDir}/config.production.json"
    [[ -d "${dataDir}/current" ]] && rm "${dataDir}/current"
    ln -f -s "${ghost}/current" "${dataDir}/current"
    [[ -d "${dataDir}/content/themes/casper" ]] && rm "${dataDir}/content/themes/casper"
    ln -f -s "${ghost}/current/content/themes/casper" "${dataDir}/content/themes/casper"
  '';

  databaseService = "mysql.service";

  serviceConfig = config.services."${serverName}";
  options = { enable = lib.mkEnableOption "${serverName} service"; };
in {
  options.services.${serverName} = options;
  config = lib.mkIf serviceConfig.enable {
    # Creates the user and group
    users.users.${userName} = {
      isSystemUser = true;
      group = userName;
      createHome = true;
      home = dataDir;
    };
    users.groups.${userName} = { };

    # Creates the Ghost config
    environment.etc."${serverName}.json".text = ''
      {
        "url": "https://${serverName}",
        "server": {
          "port": ${port},
          "host": "0.0.0.0"
        },
        "database": {
          "client": "mysql",
          "connection": {
            "host": "localhost",
            "user": "${dbUser}",
            "database": "${dbName}",
            "password": "",
            "socketPath": "/run/mysqld/mysqld.sock"
          }
        },
        "mail": {
          "transport": "sendmail"
        },
        "logging": {
          "transports": ["stdout"]
        },
        "paths": {
          "contentPath": "${dataDir}/content"
        }
      }
    '';

    # Sets up the Systemd service
    systemd.services."${serverName}" = {
      enable = true;
      description = "${serverName} ghost blog";
      restartIfChanged = true;
      restartTriggers =
        [ ghost config.environment.etc."${serverName}.json".source ];
      requires = [ databaseService ];
      after = [ databaseService ];
      path = [ pkgs.nodejs pkgs.vips ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = userName;
        Group = userName;
        WorkingDirectory = dataDir;
        # Executes the setup script before start
        ExecStartPre = setupScript;
        # Runs Ghost with node
        ExecStart = "${pkgs.nodejs}/bin/node current/index.js";
        # Sandboxes the Systemd service
        AmbientCapabilities = [ ];
        CapabilityBoundingSet = [ ];
        KeyringMode = "private";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RemoveIPC = true;
        RestrictAddressFamilies = [ ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
      environment = { NODE_ENV = "production"; };
    };

    # Sets up the blog virtual host on NGINX
    services.nginx.virtualHosts.${serverName} = {
      # Sets up Lets Encrypt SSL certificates for the blog
      forceSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:${port}"; };
      extraConfig = ''
        charset UTF-8;

        add_header Strict-Transport-Security "max-age=2592000; includeSubDomains" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin";
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Content-Type-Options nosniff;
      '';
    };

    # Sets up MySQL database and user for Ghost
    services.mysql = {
      ensureDatabases = [ dbName ];
      ensureUsers = [{
        name = dbUser;
        ensurePermissions = { "${dbName}.*" = "ALL PRIVILEGES"; };
      }];
    };
  };
}
