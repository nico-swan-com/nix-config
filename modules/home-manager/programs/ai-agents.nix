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
  t3CliPrefix = "${config.xdg.dataHome}/t3code-cli";
  yamlFormat = pkgs.formats.yaml { };

  litellmUrl = "http://${cfg.litellm.host}:${toString cfg.litellm.port}";
  localClientHost = host: if host == "0.0.0.0" || host == "::" then "127.0.0.1" else host;
  paperclipBindHost = if cfg.exposeOnLan then "0.0.0.0" else cfg.paperclip.host;
  t3codeBindHost = if cfg.exposeOnLan then "0.0.0.0" else cfg.t3code.host;
  paperclipUrl = "http://${localClientHost paperclipBindHost}:${toString cfg.paperclip.port}";
  t3codeUrl = "http://${localClientHost t3codeBindHost}:${toString cfg.t3code.port}";

  litellmConfigFile = yamlFormat.generate "litellm-config.yaml" {
    model_list = [
      {
        model_name = "openrouter-smart";
        litellm_params = {
          model = "openrouter/openrouter/free";
          api_key = "os.environ/OPENROUTER_API_KEY";
          api_base = "https://openrouter.ai/api/v1";
          drop_params = true;
        };
      }
      {
        model_name = "openrouter-free";
        litellm_params = {
          model = "openrouter/openrouter/free";
          api_key = "os.environ/OPENROUTER_API_KEY";
          api_base = "https://openrouter.ai/api/v1";
          drop_params = true;
        };
      }
      {
        model_name = "openrouter-auto";
        litellm_params = {
          model = "openrouter/openrouter/auto";
          api_key = "os.environ/OPENROUTER_API_KEY";
          api_base = "https://openrouter.ai/api/v1";
          drop_params = true;
        };
      }
      {
        model_name = "openrouter-auto-code";
        litellm_params = {
          model = "openrouter/openrouter/auto-code";
          api_key = "os.environ/OPENROUTER_API_KEY";
          api_base = "https://openrouter.ai/api/v1";
          drop_params = true;
        };
      }
    ];

    router_settings = {
      num_retries = 2;
      retry_after = 2;
      allowed_fails = 2;
      cooldown_time = 15;
      fallbacks = [
        {
          openrouter-smart = [ "openrouter-auto" ];
        }
      ];
      context_window_fallbacks = [
        {
          openrouter-smart = [ "openrouter-auto" ];
        }
      ];
    };

    litellm_settings = {
      drop_params = true;
      request_timeout = 120;
    };
  };

  agentPackages = [
    pkgs.nodejs_24
    pkgs.git
    pkgs.gh
    pkgs.glab
    pkgs.ripgrep
    pkgs.curl
    pkgs.coreutils
    pkgs.bash
    pkgs.unstable.opencode
    pkgs.unstable.cursor-cli
  ]
  ++ optional cfg.litellm.enable cfg.litellm.package;

  # PATH shared by systemd user services (Paperclip & T3 Code) so both can find
  # host-installed coding agents (opencode, cursor-agent/agent, ~/.gemini/bin/agy)
  # plus git, gh, glab, node, litellm, and Nix profiles.
  agentServicePath = concatStringsSep ":" (
    [
      "${homeDir}/.gemini/bin"
      "${homeDir}/.local/bin"
      "${cliPrefix}/node_modules/.bin"
      "${t3CliPrefix}/node_modules/.bin"
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
    runtimeInputs = agentPackages ++ [
      paperclipCli
      pkgs.iproute2
      pkgs.gawk
    ];
    text = ''
      DATA_DIR="''${PAPERCLIP_HOME:-${cfg.paperclip.dataDir}}"
      WORKSPACES_DIR="$DATA_DIR/workspaces"
      mkdir -p "$DATA_DIR" "$WORKSPACES_DIR"
      # Avoid running Paperclip with cwd=$HOME so local coding agents (e.g. cursor-agent --workspace <cwd>)
      # do not try to index the entire home directory during environment probes or default runs.
      cd "$WORKSPACES_DIR"

      ${optionalString cfg.exposeOnLan ''
        lan_ips="$(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4, a, "/"); print a[1]}' | paste -sd, - || true)"
        base_hosts="${concatStringsSep "," cfg.paperclip.allowedHostnames}"
        if [ -n "$lan_ips" ] && [ -n "$base_hosts" ]; then
          export PAPERCLIP_ALLOWED_HOSTNAMES="$base_hosts,$lan_ips"
        elif [ -n "$lan_ips" ]; then
          export PAPERCLIP_ALLOWED_HOSTNAMES="$lan_ips"
        elif [ -n "$base_hosts" ]; then
          export PAPERCLIP_ALLOWED_HOSTNAMES="$base_hosts"
        fi
      ''}

      # Bootstrap ~/.paperclip with embedded PostgreSQL on first start.
      if [ ! -f "$DATA_DIR/instances/default/config.json" ]; then
        paperclipai onboard --yes ${optionalString cfg.exposeOnLan "--bind lan "}--data-dir "$DATA_DIR"
      fi

      exec paperclipai run --data-dir "$DATA_DIR"
    '';
  };

  t3Cli = pkgs.writeShellApplication {
    name = "t3";
    runtimeInputs = [
      pkgs.nodejs_24
      pkgs.coreutils
    ];
    text = ''
      T3_PREFIX="${t3CliPrefix}"
      BIN="$T3_PREFIX/node_modules/.bin/t3"

      if [ ! -x "$BIN" ]; then
        mkdir -p "$T3_PREFIX"
        echo "Installing t3 (T3 Code) into $T3_PREFIX ..." >&2
        npm install --prefix "$T3_PREFIX" --no-audit --no-fund t3@latest
      fi

      exec "$BIN" "$@"
    '';
  };

  t3Update = pkgs.writeShellApplication {
    name = "t3-update";
    runtimeInputs = [
      pkgs.nodejs_24
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      T3_PREFIX="${t3CliPrefix}"
      mkdir -p "$T3_PREFIX"

      echo "Installing/updating t3@latest in $T3_PREFIX ..."
      npm install --prefix "$T3_PREFIX" --no-audit --no-fund t3@latest

      if systemctl --user is-active --quiet t3code.service; then
        echo "Restarting t3code.service ..."
        systemctl --user restart t3code.service
      fi
    '';
  };

  t3codeServer = pkgs.writeShellApplication {
    name = "t3code-server";
    runtimeInputs = agentPackages ++ [ t3Cli ];
    text = ''
      HOST_ADDR="${t3codeBindHost}"
      PORT_NUM="${toString cfg.t3code.port}"

      if t3 serve --help >/dev/null 2>&1; then
        exec t3 serve --host "$HOST_ADDR" --port "$PORT_NUM" --no-browser
      else
        exec t3 --host "$HOST_ADDR" --port "$PORT_NUM" --no-browser
      fi
    '';
  };

  paperclipT3Bridge = pkgs.writeShellApplication {
    name = "paperclip-t3-bridge";
    runtimeInputs = [ pkgs.curl ];
    text = ''
            T3_URL="''${T3CODE_URL:-${t3codeUrl}}"

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
      pkgs.iproute2
      pkgs.gawk
      pkgs.coreutils
    ];
    text = ''
      export PATH="${agentServicePath}:''${PATH:-}"

      echo "=== Services ==="
      for unit in litellm.service paperclip.service t3code.service; do
        load_state="$(systemctl --user show -p LoadState --value "$unit" 2>/dev/null || true)"
        if [ "$load_state" = "loaded" ]; then
          state="$(systemctl --user is-active "$unit" || true)"
          printf "  %-24s %s\n" "$unit" "$state"
        fi
      done

      echo ""
      echo "=== Local Endpoints ==="
      if curl -fsS --max-time 2 "${litellmUrl}/health/liveliness" >/dev/null 2>&1; then
        echo "  LiteLLM   : ${litellmUrl}/v1 (reachable, loopback-only)"
      else
        echo "  LiteLLM   : ${litellmUrl}/v1 (not responding)"
      fi
      if curl -fsS --max-time 2 "${paperclipUrl}" >/dev/null 2>&1; then
        echo "  Paperclip : ${paperclipUrl} (reachable)"
      else
        echo "  Paperclip : ${paperclipUrl} (not responding)"
      fi
      if curl -fsS --max-time 2 "${t3codeUrl}" >/dev/null 2>&1; then
        echo "  T3 Code   : ${t3codeUrl} (reachable)"
      else
        echo "  T3 Code   : ${t3codeUrl} (not responding)"
      fi

      ${optionalString cfg.exposeOnLan ''
        echo ""
        echo "=== LAN URLs (from other devices on your network) ==="
        host_raw="$(uname -n 2>/dev/null || true)"
        host_short="''${host_raw%%.*}"
        if [ -n "$host_short" ]; then
          echo "  Paperclip : http://$host_short.local:${toString cfg.paperclip.port}"
          echo "  T3 Code   : http://$host_short.local:${toString cfg.t3code.port}"
        fi
        while IFS= read -r ip_addr; do
          [ -z "$ip_addr" ] && continue
          echo "  Paperclip : http://$ip_addr:${toString cfg.paperclip.port}"
          echo "  T3 Code   : http://$ip_addr:${toString cfg.t3code.port}"
        done < <(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4, a, "/"); print a[1]}')
      ''}

      echo ""
      echo "=== Coding Agent CLIs on service PATH ==="
      for bin in opencode cursor-agent agent agy t3 litellm paperclipai node git gh glab rg; do
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
    enable = mkEnableOption "Native Paperclip control plane + T3 Code + LiteLLM + local coding agents stack";

    exposeOnLan = mkOption {
      type = types.bool;
      default = false;
      description = "Bind Paperclip (:3100) and T3 Code (:3773) to 0.0.0.0 for LAN access while keeping LiteLLM loopback-only.";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "${config.xdg.configHome}/ai-agents/env";
      description = "Shared optional systemd EnvironmentFile (OPENROUTER_API_KEY, etc.) loaded by litellm, paperclip, and t3code.";
    };

    litellm = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the local LiteLLM proxy systemd user service for OpenRouter free->auto routing.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.litellm;
        description = "LiteLLM package to run as the local proxy.";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host interface LiteLLM binds to.";
      };

      port = mkOption {
        type = types.port;
        default = 4000;
        description = "TCP port LiteLLM listens on.";
      };
    };

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
        type = types.nullOr types.str;
        default = null;
        description = "Optional extra systemd EnvironmentFile loaded by paperclip.service.";
      };

      allowedHostnames = mkOption {
        type = types.listOf types.str;
        default = [
          "localhost"
          "127.0.0.1"
        ];
        description = "Extra hostnames added to PAPERCLIP_ALLOWED_HOSTNAMES when exposeOnLan is enabled (LAN IPv4 addresses are added automatically).";
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
        description = "Optional extra systemd EnvironmentFile loaded by t3code.service.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.glab
      pkgs.ripgrep
      pkgs.unstable.antigravity-ide
      pkgs.unstable.cursor-cli
      t3Cli
      t3Update
      paperclipCli
      paperclipUpdate
      paperclipT3Bridge
      aiStackStatus
    ]
    ++ optional cfg.litellm.enable cfg.litellm.package;

    # Ensure ~/.gemini/bin (Antigravity `agy` binary) and ~/.local/bin are on shell PATH.
    home.sessionPath = [
      "${homeDir}/.gemini/bin"
      "${homeDir}/.local/bin"
    ];

    # Source shared ~/.config/ai-agents/env in interactive zsh sessions if present.
    programs.zsh.initContent = lib.mkAfter ''
      if [ -f "${cfg.environmentFile}" ]; then
        set -a
        # shellcheck disable=SC1090
        source "${cfg.environmentFile}"
        set +a
      fi
    '';

    # Export agent CLIs and service URLs to systemd user services.
    xdg.configFile."environment.d/20-ai-agents.conf".text = ''
      PATH=${agentServicePath}:''${PATH}
      LITELLM_URL=${litellmUrl}
      T3CODE_URL=${t3codeUrl}
      PAPERCLIP_URL=${paperclipUrl}
    '';

    # Shared env file template (copy to ~/.config/ai-agents/env and chmod 600).
    xdg.configFile."ai-agents/env.example".text = ''
      # Copy this file to ${cfg.environmentFile} and chmod 600:
      #   cp ${config.xdg.configHome}/ai-agents/env.example ${cfg.environmentFile}
      #   chmod 600 ${cfg.environmentFile}
      # Then restart services:
      #   systemctl --user restart litellm.service paperclip.service t3code.service
      #
      # Required for OpenRouter (used by LiteLLM free->auto routing & OpenCode):
      # OPENROUTER_API_KEY=sk-or-v1-...
      #
      # Optional additional provider / GitLab tokens:
      # ANTHROPIC_API_KEY=
      # OPENAI_API_KEY=
      # GEMINI_API_KEY=
      # CURSOR_API_KEY=
      # GITLAB_TOKEN=
      # GITLAB_HOST=gitlab.com
    '';

    xdg.configFile."litellm/config.yaml" = mkIf cfg.litellm.enable {
      source = litellmConfigFile;
    };

    # OpenCode configured with both local LiteLLM (free->auto failover) and direct OpenRouter.
    # Used by both Paperclip (opencode_local) and T3 Code (opencode provider).
    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      settings = {
        autoupdate = false;
        model = if cfg.litellm.enable then "litellm/openrouter-smart" else "openrouter/openrouter/free";
        provider = {
          openrouter = {
            options = {
              apiKey = "{env:OPENROUTER_API_KEY}";
            };
            models = {
              "openrouter/free" = {
                name = "OpenRouter Free (Direct)";
              };
              "openrouter/auto" = {
                name = "OpenRouter Auto (Direct)";
              };
              "openrouter/auto-code" = {
                name = "OpenRouter Auto Code (Direct)";
              };
            };
          };
        }
        // optionalAttrs cfg.litellm.enable {
          litellm = {
            npm = "@ai-sdk/openai-compatible";
            name = "LiteLLM (OpenRouter Router)";
            options = {
              baseURL = "${litellmUrl}/v1";
              apiKey = "local-litellm";
            };
            models = {
              "openrouter-smart" = {
                name = "OpenRouter Free -> Auto Fallback (LiteLLM)";
                limit = {
                  context = 128000;
                  output = 16384;
                };
              };
              "openrouter-free" = {
                name = "OpenRouter Free Only (LiteLLM)";
                limit = {
                  context = 128000;
                  output = 16384;
                };
              };
              "openrouter-auto" = {
                name = "OpenRouter Auto (LiteLLM)";
                limit = {
                  context = 200000;
                  output = 16384;
                };
              };
              "openrouter-auto-code" = {
                name = "OpenRouter Auto Code (LiteLLM)";
                limit = {
                  context = 200000;
                  output = 16384;
                };
              };
            };
          };
        };
      };
    };

    # Local LiteLLM proxy on :4000 (openrouter/free with automatic fallback to openrouter/auto)
    systemd.user.services.litellm = mkIf cfg.litellm.enable {
      Unit = {
        Description = "LiteLLM OpenAI-Compatible Proxy (OpenRouter free -> auto)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.litellm.package}/bin/litellm --config ${litellmConfigFile} --host ${cfg.litellm.host} --port ${toString cfg.litellm.port}";
        WorkingDirectory = homeDir;
        EnvironmentFile = "-${cfg.environmentFile}";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # T3 Code settings (package = null avoids nixpkgs's broken bun/vite source build of t3code-0.0.24;
    # T3 Code is installed via npm `t3@latest` in ~/.local/share/t3code-cli by the `t3` wrapper).
    programs.t3code = mkIf cfg.t3code.enable {
      enable = true;
      package = null;
      mutableUserSettings = true;
    };

    # T3 Code background server on :3773
    systemd.user.services.t3code = mkIf cfg.t3code.enable {
      Unit = {
        Description = "T3 Code Agent Control Surface Server";
        After = [ "network-online.target" ] ++ optional cfg.litellm.enable "litellm.service";
        Wants = [ "network-online.target" ] ++ optional cfg.litellm.enable "litellm.service";
      };

      Service = {
        Type = "simple";
        ExecStart = "${t3codeServer}/bin/t3code-server";
        WorkingDirectory = homeDir;
        Environment = [
          "T3CODE_HOST=${t3codeBindHost}"
          "T3CODE_PORT=${toString cfg.t3code.port}"
          "LITELLM_URL=${litellmUrl}"
          "PAPERCLIP_URL=${paperclipUrl}"
          "PATH=${agentServicePath}"
        ];
        EnvironmentFile = [
          "-${cfg.environmentFile}"
        ]
        ++ optional (cfg.t3code.environmentFile != null) "-${cfg.t3code.environmentFile}";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = 180;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Paperclip AI control plane (embedded PostgreSQL under ~/.paperclip, :3100)
    systemd.user.services.paperclip = mkIf cfg.paperclip.enable {
      Unit = {
        Description = "Paperclip AI Agent Control Plane";
        After = [ "network-online.target" ] ++ optional cfg.litellm.enable "litellm.service";
        Wants = [ "network-online.target" ] ++ optional cfg.litellm.enable "litellm.service";
      };

      Service = {
        Type = "simple";
        ExecStart = "${paperclipServer}/bin/paperclip-server";
        WorkingDirectory = homeDir;
        Environment = [
          "PAPERCLIP_HOME=${cfg.paperclip.dataDir}"
          "HOST=${paperclipBindHost}"
          "PORT=${toString cfg.paperclip.port}"
          "LITELLM_URL=${litellmUrl}"
          "T3CODE_URL=${t3codeUrl}"
          "PATH=${agentServicePath}"
        ]
        ++ optional cfg.exposeOnLan "PAPERCLIP_BIND=lan";
        EnvironmentFile = [
          "-${cfg.environmentFile}"
        ]
        ++ optional (cfg.paperclip.environmentFile != null) "-${cfg.paperclip.environmentFile}";
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
