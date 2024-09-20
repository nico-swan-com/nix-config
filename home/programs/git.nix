{ config, userSettings, ... }:

{
  programs.git = {
    enable = true;
    userName = "Nico Swan";
    userEmail = "hi@nicoswan.com";
    extraConfig = {
      init.defaultBranch = "main";
    };

  };


}
