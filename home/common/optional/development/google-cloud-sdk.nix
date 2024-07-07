{ pkgs, config, ... }:
{

  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.cloud_sql_proxy
      google-cloud-sdk.components.pubsub-emulator
      google-cloud-sdk.components.kubectl
    ])
  ];

  # Configure  google-cloud-sdk auto complete
  programs.zsh = {
    sessionVariables = {
      CLOUD_SDK_HOME = "${pkgs.google-cloud-sdk}";
      GOOGLE_APPLICATION_CREDENTIALS = "${config.home.homeDirectory}/.config/gcloud/application_default_credentials.json";
      GOOGLE_SERVICE_KEY_PATH = "${config.home.homeDirectory}/.config/gcloud/application_default_credentials.json";
    };

    initExtra = ''
      source "$CLOUD_SDK_HOME/google-cloud-sdk/path.zsh.inc"
    '';
  };
}
