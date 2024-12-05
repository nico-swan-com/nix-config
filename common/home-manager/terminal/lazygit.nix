{pkgs, ...}:{
 
  home.packages = with pkgs; [
    delta
  ];
   
  programs.lazygit = {
    enable = true;

    # custom settings
     settings = {
       git = {
          paging = {
              colorArg = "never";
              pager= "delta --dark --paging=never --color-only --line-numbers";
              # pager: ydiff -p cat -s --wrap --width={{columnWidth}}   
              useConfig = false;
            };
       };
    };
  };
}
