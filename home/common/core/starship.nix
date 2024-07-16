{
  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = true;
      docker_context.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = false;
      command_timeout = 1000;
    };
  };
}
