{ pkgs, config, cfg, ... }: {
  sops.secrets.google_api_key = {
    owner = cfg.username;
  };

  environment.sessionVariables = {
    GOOGLE_API_KEY = "$(cat ${config.sops.secrets.google_api_key.path})";
  };

  environment.systemPackages = with pkgs;
    [
      gemini-cli
      #claude-code
      #open-interpreter
      #ollama
      #oterm

      #vimPlugins.ollama-nvim
    ];
}
