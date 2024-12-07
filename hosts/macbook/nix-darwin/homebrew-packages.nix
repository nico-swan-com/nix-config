{
  #############################################
  #  Packages that is installed via Homebrew  #
  #############################################
  # This is to be used only if the packages and 
  # application is not availible in nix and need 
  # to be installed with homebrew 
  # For homebrew to work, you need to install 
  # the command line tools execute the following
  #
  # /bin/bash - c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # 
  homebrew = {
    enable = true;
    brews = [ "nvm" ];
    casks = [
      "iterm2"
      "rectangle"
      "datagrip" # SQL IDE
      "postman" # REST API testing
      "capcut" # Video editing
      "gather" # Gather Town
      "sourcetree" # Git manager 
      "bing-wallpaper" # Random wallpapers
      "inkscape" # Graphics tool for SVGs
      "gimp" # Graphics tool
      "cryptomator" # Encrypt oneline storage files
      #"ksnip"          # Screen capture

      # -- Security --
      #"1password"
    ];
  };
}
