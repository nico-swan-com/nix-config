{
  pkgs,
  config,
  cfg,
  ...
}:
let
  homeDirectory = "/home/nicoswan";
in
{
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
  sops.secrets.google_api_key = {
    owner = cfg.username;
  };

  environment.sessionVariables = {
    GOOGLE_API_KEY = "$(cat ${config.sops.secrets.google_api_key.path})";
    GEMINI_API_KEY = "$(cat ${config.sops.secrets.google_api_key.path})";
  };

  environment.systemPackages =
    with pkgs;
    [
      gemini-cli
      claude-code
      #open-interpreter
      #ollama
      #oterm

      #vimPlugins.ollama-nvim
    ]
    ++ (with pkgs.unstable; [
      #openclaw
    ]);
}
