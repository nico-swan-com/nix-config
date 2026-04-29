# OpenClaw gateway (Telegram → local tools) via github:openclaw/nix-openclaw
#
# LLM: Google Gemini via CLI OAuth (`google-gemini-cli/*`). Tokens live in OpenClaw’s auth store
# under ~/.openclaw after you log in (not in sops). See:
# https://docs.openclaw.ai/concepts/model-providers (Google Vertex and Gemini CLI)
#
# After `nixos-rebuild switch`, run once (interactive browser OAuth):
#   openclaw models auth login --provider google-gemini-cli --set-default
#
# You need `gemini-cli` on PATH (this host installs it in hosts/dell-laptop/packages/ai.nix).
# If the gateway cannot find the CLI, set GOOGLE_CLOUD_PROJECT or GOOGLE_CLOUD_PROJECT_ID
# for your GCP project (see upstream docs).
{ config, lib, ... }:
let
  homeDirectory = config.home.homeDirectory;
  telegramTokenFile = config.sops.secrets."users/nicoswan/openclaw/telegram-bot-token".path;
in
{
  # Telegram bot token: plain text file, one line (see comment block at bottom).
  sops.secrets = {
    "users/nicoswan/openclaw/telegram-bot-token" = {
      path = "${homeDirectory}/.secrets/openclaw/telegram-bot-token";
      mode = "0400";
    };
    "users/nicoswan/openclaw/google-api-key" = {
      path = "${homeDirectory}/.secrets/openclaw/google-api-key";
      mode = "0400";
    };
  };

  # Both vars: OpenClaw prefers GEMINI_API_KEY; some tools only read GOOGLE_API_KEY.
  sops.templates."openclaw-gemini.env".content = ''
    GEMINI_API_KEY=${config.sops.placeholder."users/nicoswan/openclaw/google-api-key"}
    GOOGLE_API_KEY=${config.sops.placeholder."users/nicoswan/openclaw/google-api-key"}
  '';

  programs.openclaw = {
    documents = ./openclaw-documents;

    bundledPlugins.summarize.enable = true;

    config = {
      agents.defaults.model = "google-gemini-cli/gemini-3-flash-preview";

      gateway = {
        mode = "local";
        auth.mode = "none";
      };

      channels.telegram = {
        tokenFile = toString telegramTokenFile;
        # Replace with your numeric user id from https://t.me/userinfobot
        allowFrom = [ 123456789 ];
        groups = {
          "*" = {
            requireMention = true;
          };
        };
      };
    };

    instances.default = {
      enable = true;
    };
  };
}
