{
  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = true;
      docker_context.disabled = true;
      aws.disabled = true;
      gcloud.disabled = false;
      line_break.disabled = true;
      command_timeout = 1000;
    };
  };
}
