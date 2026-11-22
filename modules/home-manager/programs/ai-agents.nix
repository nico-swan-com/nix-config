{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.nicoswan.ai-agents;

  homeDir = config.home.homeDirectory;
  username = config.home.username;
  cliPrefix = "${config.xdg.dataHome}/paperclip-cli";

  agentPackages = [
    pkgs.nodejs_24
    pkgs.git
    pkgs.gh
    pkgs.glab
    pkgs.ripgrep
    pkgs.curl
    pkgs.coreutils
    pkgs.bash
    pkgs.t3code
    pkgs.unstable.opencode
    pkgs.unstable.cursor-cli
  ];

  # PATH shared by systemd user services (Paperclip & T3 Code) so both can find
  # host-installed coding agents (opencode, cursor-agent/agent, ~/.gemini/bin/agy)
  # plus git, gh, node, and Nix profiles.
  agentServicePath = concatStringsSep ":" (
    [
      "${homeDir}/.gemini/bin"
      "${homeDir}/.local/bin"
      "${cliPrefix}/node_modules/.bin"
      "/etc/profiles/per-user/${username}/bin"
      "/run/current-system/sw/bin"
    ]
    ++ (map (p: "${p}/bin") agentPackages)
  );

  paperclipCli = pkgs.writeShellApplication {
    name = "paperclipai";
    runtimeInputs = [
      pkgs.nodejs_24
      pkgs.coreutils
    ];
    text = ''
      CLI_PREFIX="${cliPrefix}"
      BIN="$CLI_PREFIX/node_modules/.bin/paperclipai"

      if [ ! -x "$BIN" ]; then
        mkdir -p "$CLI_PREFIX"
        echo "Installing paperclipai into $CLI_PREFIX ..." >&2
        npm install --prefix "$CLI_PREFIX" --no-audit --no-fund paperclipai@latest
      fi

      exec "$BIN" "$@"
    '';
  };

  paperclipUpdate = pkgs.writeShellApplication {
    name = "paperclipai-update";
    runtimeInputs = [
      pkgs.nodejs_24
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      CLI_PREFIX="${cliPrefix}"
      mkdir -p "$CLI_PREFIX"

      packages=("paperclipai@latest")
      for arg in "$@"; do
        case "$arg" in
          --with-antigravity-adapter)
            packages+=("@weslleycapelari/adapter-antigravity-local@latest")
            ;;
        esac
      done

      echo "Installing/updating: ''${packages[*]} in $CLI_PREFIX ..."
      npm install --prefix "$CLI_PREFIX" --no-audit --no-fund "''${packages[@]}"

      if systemctl --user is-active --quiet paperclip.service; then
        echo "Restarting paperclip.service ..."
        systemctl --user restart paperclip.service
      fi
    '';
  };

  paperclipServer = pkgs.writeShellApplication {
    name = "paperclip-server";
    runtimeInputs = agentPackages ++ [ paperclipCli ];
    text = ''
      DATA_DIR="''${PAPERCLIP_HOME:-${cfg.paperclip.dataDir}}"
      mkdir -p "$DATA_DIR"

      # Bootstrap ~/.paperclip with embedded PostgreSQL on first start.
      if [ ! -f "$DATA_DIR/instances/default/config.json" ]; then
        paperclipai onboard --yes --data-dir "$DATA_DIR"
      fi

      exec paperclipai run --data-dir "$DATA_DIR"
    '';
  };

  t3codeServer = pkgs.writeShellApplication {
    name = "t3code-server";
    runtimeInputs = agentPackages;
    text = ''
      HOST_ADDR="${cfg.t3code.host}"
      PORT_NUM="${toString cfg.t3code.port}"

      if t3code serve --help >/dev/null 2>&1; then
        exec t3code serve --host "$HOST_ADDR" --port "$PORT_NUM" --no-browser
      else
        exec t3code --host "$HOST_ADDR" --port "$PORT_NUM" --no-browser
      fi
    '';
  };

  paperclipT3Bridge = pkgs.writeShellApplication {
    name = "paperclip-t3-bridge";
    runtimeInputs = [ pkgs.curl ];
    text = ''
            T3_URL="''${T3CODE_URL:-http://${cfg.t3code.host}:${toString cfg.t3code.port}}"

            if [ "$#" -lt 2 ]; then
              cat <<EOF
      Usage:
        paperclip-t3-bridge <taskId> <token> [json-payload]

      Trigger a T3 Code webhook task manually, or paste this URL into a Paperclip
      agent using Paperclip's built-in "http" adapter:

        $T3_URL/api/hooks/<taskId>/<token>

      Example:
        paperclip-t3-bridge my-task-id my-secret-token '{"prompt":"Review latest PR"}'
      EOF
              exit 0
            fi

            TASK_ID="$1"
            TOKEN="$2"
            if [ "$#" -ge 3 ]; then
              PAYLOAD="$3"
            else
              PAYLOAD="{}"
            fi

            exec curl -fsS -X POST \
              -H "Content-Type: application/json" \
              -d "$PAYLOAD" \
              "$T3_URL/api/hooks/$TASK_ID/$TOKEN"
    '';
  };

  aiStackStatus = pkgs.writeShellApplication {
    name = "ai-stack-status";
    runtimeInputs = [
      pkgs.curl
      pkgs.systemd
    ];
    text = ''
      export PATH="${agentServicePath}:''${PATH:-}"

      echo "=== Services ==="
      for unit in paperclip.service t3code.service t3code-server.service; do
        load_state="$(systemctl --user show -p LoadState --value "$unit" 2>/dev/null || true)"
        if [ "$load_state" = "loaded" ]; then
          state="$(systemctl --user is-active "$unit" || true)"
          printf "  %-24s %s\n" "$unit" "$state"
        fi
      done

      echo ""
      echo "=== Endpoints ==="
      paperclip_url="http://${cfg.paperclip.host}:${toString cfg.paperclip.port}"
      t3_url="http://${cfg.t3code.host}:${toString cfg.t3code.port}"
      if curl -fsS --max-time 2 "$paperclip_url" >/dev/null 2>&1; then
        echo "  Paperclip : $paperclip_url (reachable)"
      else
        echo "  Paperclip : $paperclip_url (not responding)"
      fi
      if curl -fsS --max-time 2 "$t3_url" >/dev/null 2>&1; then
        echo "  T3 Code   : $t3_url (reachable)"
      else
        echo "  T3 Code   : $t3_url (not responding)"
      fi

      echo ""
      echo "=== Coding Agent CLIs on service PATH ==="
      for bin in opencode cursor-agent agent agy t3 t3code paperclipai node git gh glab rg; do
        if loc="$(command -v "$bin" 2>/dev/null)"; then
          printf "  %-14s %s\n" "$bin" "$loc"
        else
          printf "  %-14s %s\n" "$bin" "(not found)"
        fi
      done
    '';
  };
in
{
  options.programs.nicoswan.ai-agents = {
    enable = mkEnableOption "Native Paperclip control plane + T3 Code + local coding agents stack";

    paperclip = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the Paperclip AI control plane systemd user service.";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host interface Paperclip binds to.";
      };

      port = mkOption {
        type = types.port;
        default = 3100;
        description = "TCP port Paperclip listens on.";
      };

      dataDir = mkOption {
        type = types.str;
        default = "${homeDir}/.paperclip";
        description = "Directory for Paperclip state and embedded PostgreSQL database.";
      };

      environmentFile = mkOption {
        type = types.str;
        default = "${config.xdg.configHome}/paperclip/env";
        description = "Optional systemd EnvironmentFile for API keys and Paperclip overrides.";
      };
    };

    t3code = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable T3 Code and its background server user service.";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host interface T3 Code server binds to.";
      };

      port = mkOption {
        type = types.port;
        default = 3773;
        description = "TCP port T3 Code server listens on.";
      };

      environmentFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional systemd EnvironmentFile loaded by t3code.service.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.glab
      pkgs.ripgrep
      pkgs.unstable.antigravity-ide
      pkgs.unstable.cursor-cli
      pkgs.unstable.opencode
      paperclipCli
      paperclipUpdate
      paperclipT3Bridge
      aiStackStatus
    ];

    # Ensure ~/.gemini/bin (Antigravity `agy` binary) and ~/.local/bin are on shell PATH.
    home.sessionPath = [
      "${homeDir}/.gemini/bin"
      "${homeDir}/.local/bin"
    ];

    # Export agent CLIs to systemd user services (covers both t3code and paperclip).
    xdg.configFile."environment.d/20-ai-agents.conf".text = ''
      PATH=${agentServicePath}:''${PATH}
      T3CODE_URL=http://${cfg.t3code.host}:${toString cfg.t3code.port}
      PAPERCLIP_URL=http://${cfg.paperclip.host}:${toString cfg.paperclip.port}
    '';

    # Example env file for optional provider API keys (copy to ~/.config/paperclip/env).
    xdg.configFile."paperclip/env.example".text = ''
      # Copy this file to ${cfg.paperclip.environmentFile} and chmod 600 if you want
      # Paperclip agents to use API keys in addition to local subscription OAuth.
      #
      # ANTHROPIC_API_KEY=
      # OPENAI_API_KEY=
      # GEMINI_API_KEY=
      # CURSOR_API_KEY=
      # GITLAB_TOKEN=
      # GITLAB_HOST=gitlab.com
    '';

    # T3 Code package + settings (Home Manager release-26.05 does not include a server submodule)
    programs.t3code = mkIf cfg.t3code.enable {
      enable = true;
      package = pkgs.t3code;
      mutableUserSettings = true;
    };

    # T3 Code background server on :3773
    systemd.user.services.t3code = mkIf cfg.t3code.enable {
      Unit = {
        Description = "T3 Code Agent Control Surface Server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service =
        {
          Type = "simple";
          ExecStart = "${t3codeServer}/bin/t3code-server";
          WorkingDirectory = homeDir;
          Environment = [
            "T3CODE_HOST=${cfg.t3code.host}"
            "T3CODE_PORT=${toString cfg.t3code.port}"
            "PAPERCLIP_URL=http://${cfg.paperclip.host}:${toString cfg.paperclip.port}"
            "PATH=${agentServicePath}"
          ];
          Restart = "on-failure";
          RestartSec = 5;
        }
        // optionalAttrs (cfg.t3code.environmentFile != null) {
          EnvironmentFile = "-${cfg.t3code.environmentFile}";
        };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Paperclip AI control plane (embedded PostgreSQL under ~/.paperclip, :3100)
    systemd.user.services.paperclip = mkIf cfg.paperclip.enable {
      Unit = {
        Description = "Paperclip AI Agent Control Plane";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${paperclipServer}/bin/paperclip-server";
        WorkingDirectory = homeDir;
        Environment = [
          "PAPERCLIP_HOME=${cfg.paperclip.dataDir}"
          "HOST=${cfg.paperclip.host}"
          "PORT=${toString cfg.paperclip.port}"
          "T3CODE_URL=http://${cfg.t3code.host}:${toString cfg.t3code.port}"
          "PATH=${agentServicePath}"
        ];
        EnvironmentFile = "-${cfg.paperclip.environmentFile}";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = 180;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
