{ configVars, ... }:
{
  imports = [
    ./core
  ];

  # Let Home Manager install and manage itself.
  home.stateVersion = configVars.stateVersion;
  programs.home-manager.enable = true;

}
