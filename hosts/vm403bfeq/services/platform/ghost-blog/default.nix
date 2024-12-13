{ config, pkgs, ... }:
let
  serverName = "blog.platform.cygnus-labs.com";
  # port on which the Ghost service runs
  port = "1357";
  # user used to run the Ghost service
  userName = builtins.replaceStrings [ "." ] [ "_" ] serverName;
  # MySQL database used by Ghost
  dbName = userName;
  # MySQL user used by Ghost
  dbUser = userName;
  # directory used to save the blog content
  dataDir = "/var/lib/${userName}";

  # script that sets up the Ghost content directory
  setupScript = pkgs.writeScript "${serverName}-setup.sh" ''
      #! ${pkgs.stdenv.shell} -e
      chmod g+s "${dataDir}"
      ${pkgs.ghost-cli}/bin/ghost install --db=sqlite3 \
    --no-enable --no-prompt --no-stack --no-setup --no-start --dir ${dataDir}
  '';
  databaseService = "mysql.service";
  serviceConfig = config.services."${serverName}";
  #options = { enable = lib.mkEnableOption "${serverName} service"; };
in {

  environment.systemPackages = with pkgs; [ ghost-cli ];

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
    restartTriggers = [
      "${pkgs.ghost-cli}/bin/ghost"
      config.environment.etc."${serverName}.json".source
    ];
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

}
