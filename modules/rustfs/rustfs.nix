{ config, pkgs, lib, ... }:

let
  cfg = config.services.rustfs;
  
  # Generate the volumes string based on deployment mode
  volumesString = 
    if cfg.deploymentMode == "snsd" then
      "http://${cfg.address}:${toString cfg.port}${cfg.dataDir}"
    else if cfg.deploymentMode == "snmd" then
      let
        volumes = lib.concatMapStringsSep " " (disk: 
          "http://${cfg.address}:${toString cfg.port}${disk}"
        ) cfg.dataDirs;
      in volumes
    else # mnmd
      let
        nodeVolumes = lib.concatMapStringsSep " " (node: 
          let
            nodeVolumes = lib.concatMapStringsSep " " (disk: 
              "http://${node}:${toString cfg.port}${disk}"
            ) cfg.dataDirs;
          in nodeVolumes
        ) cfg.nodes;
      in nodeVolumes;

  # Environment file content
  envFile = pkgs.writeText "rustfs.env" ''
    RUSTFS_ACCESS_KEY=${cfg.accessKey}
    RUSTFS_SECRET_KEY=${cfg.secretKey}
    RUSTFS_VOLUMES="${volumesString}"
    RUSTFS_ADDRESS=":${toString cfg.port}"
    RUSTFS_CONSOLE_ENABLE=${if cfg.console.enable then "true" else "false"}
    RUST_LOG=${cfg.logLevel}
    RUSTFS_OBS_LOG_DIRECTORY="${cfg.logDir}/"
    ${lib.optionalString (cfg.tls.enable) ''
    RUSTFS_CERT_FILE="${cfg.tls.certFile}"
    RUSTFS_KEY_FILE="${cfg.tls.keyFile}"
    ''}
  '';

in
{
  options.services.rustfs = {
    enable = lib.mkEnableOption "RustFS object storage service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rustfs;
      description = "The RustFS package to use.";
    };

    deploymentMode = lib.mkOption {
      type = lib.types.enum [ "snsd" "snmd" "mnmd" ];
      default = "snsd";
      description = ''
        Deployment mode:
        - snsd: Single Node Single Disk
        - snmd: Single Node Multiple Disk  
        - mnmd: Multiple Node Multiple Disk
      '';
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to bind the service to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "Port to bind the service to.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/rustfs";
      description = "Data directory for single disk mode.";
    };

    dataDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/data/rustfs0" "/data/rustfs1" "/data/rustfs2" "/data/rustfs3" ];
      description = "Data directories for multiple disk modes.";
    };

    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "node1" "node2" "node3" "node4" ];
      description = "Node hostnames for multiple node mode.";
    };

    accessKey = lib.mkOption {
      type = lib.types.str;
      default = "rustfsadmin";
      description = "Access key for S3 API.";
    };

    secretKey = lib.mkOption {
      type = lib.types.str;
      default = "rustfsadmin";
      description = "Secret key for S3 API.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "rustfs";
      description = "User to run RustFS service.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "rustfs";
      description = "Group to run RustFS service.";
    };

    logDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/log/rustfs";
      description = "Directory for RustFS logs.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "error";
      description = "Log level for RustFS.";
    };

    console = {
      enable = lib.mkEnableOption "RustFS web console";
      
      port = lib.mkOption {
        type = lib.types.port;
        default = 9001;
        description = "Port for the web console.";
      };
    };

    tls = {
      enable = lib.mkEnableOption "TLS encryption";
      
      certFile = lib.mkOption {
        type = lib.types.str;
        default = "/opt/tls/public.crt";
        description = "Path to TLS certificate file.";
      };
      
      keyFile = lib.mkOption {
        type = lib.types.str;
        default = "/opt/tls/private.key";
        description = "Path to TLS private key file.";
      };
    };

    erasureCoding = {
      dataBlocks = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Number of data blocks for erasure coding.";
      };
      
      parityBlocks = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Number of parity blocks for erasure coding.";
      };
    };

    systemd = {
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Additional systemd service configuration.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create rustfs user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "RustFS object storage service user";
    };

    users.groups.${cfg.group} = {};

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d ${cfg.logDir} 0750 ${cfg.user} ${cfg.group}"
      "d /opt/tls 0750 ${cfg.user} ${cfg.group}"
    ] ++ lib.optionals (cfg.deploymentMode == "snsd") [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group}"
    ] ++ lib.optionals (cfg.deploymentMode != "snsd") (
      map (dir: "d ${dir} 0750 ${cfg.user} ${cfg.group}") cfg.dataDirs
    );

    # Systemd service
    systemd.services.rustfs = {
      description = "RustFS Object Storage Server";
      documentation = "https://docs.rustfs.com/";
      
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "main";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "/usr/local";
        EnvironmentFile = envFile;
        ExecStart = "${cfg.package}/bin/rustfs ${volumesString}";
        
        # Resource limits
        LimitNOFILE = 1048576;
        LimitNPROC = 32768;
        TasksMax = "infinity";
        
        # Restart policy
        Restart = "always";
        RestartSec = "10s";
        
        # Security settings
        OOMScoreAdjust = -1000;
        SendSIGKILL = false;
        TimeoutStartSec = "30s";
        TimeoutStopSec = "30s";
        NoNewPrivileges = true;
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        
        # Logging
        StandardOutput = "append:${cfg.logDir}/rustfs.log";
        StandardError = "append:${cfg.logDir}/rustfs-err.log";
      };
      
      wantedBy = [ "multi-user.target" ];
    } // lib.optionalAttrs (cfg.systemd.extraConfig != "") {
      extraConfig = cfg.systemd.extraConfig;
    };

    # Firewall configuration
    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedTCPPorts = [ cfg.port ] ++ lib.optionals cfg.console.enable [ cfg.console.port ];
    };

    # Environment packages
    environment.systemPackages = [ cfg.package ];

    # NixOS assertions
    assertions = [
      {
        assertion = cfg.deploymentMode != "mnmd" || (lib.length cfg.nodes >= 4);
        message = "Multiple Node Multiple Disk mode requires at least 4 nodes";
      }
      {
        assertion = cfg.deploymentMode != "snmd" || (lib.length cfg.dataDirs >= 2);
        message = "Single Node Multiple Disk mode requires at least 2 data directories";
      }
      # Note: TLS file existence checks are removed as they cause issues in pure evaluation mode
      # The systemd service will handle missing files gracefully at runtime
    ];
  };
}
