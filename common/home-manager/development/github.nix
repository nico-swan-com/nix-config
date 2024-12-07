{
  # GitHub CLI
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.gh.enable
  # Aliases config in ./gh-aliases.nix
  programs.gh = {
    enable = true;
    settings.version = 1;
    settings.git_protocol = "ssh";
  };
}
