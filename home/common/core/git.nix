{ configVars, ... }:
{
  programs.git = {
    enable = true;
    userName = configVars.fullName;
    userEmail = configVars.email;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

}
