{
  programs.ssh = {

    # extraConfig = ''
    #   AddKeysToAgent yes
    #   PreferredAuthentications publickey
    # '';

    # matchBlocks = {
    #   "gitlab" = {
    #     host = "gitlab.com";
    #     identitiesOnly = true;
    #     identityFile = [
    #       "~/.ssh/id_gitlab-key"
    #     ];
    #   };

    #   "github" = {
    #     host = "github.com";
    #     identitiesOnly = true;
    #     identityFile = [
    #       "~/.ssh/id_github-key"
    #       "~/.ssh/id_nicoswan"
    #     ];
    #   };

    #   "vm403bfeq.cygnus-labs.com" = {
    #     host = "102.135.163.95";
    #     identitiesOnly = false;
    #     identityFile = [
    #       "~/.ssh/id_nicoswan"
    #       "~/.ssh/vm403bfeq"
    #     ];
    #   };

    # };
  };
}
