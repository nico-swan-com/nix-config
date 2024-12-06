   { lib, builtins, pkgs, ... }:

let
  # Replace with the URL of your GitHub repository
  repo = builtins.fetchGit {
    url = "git+ssh://git@github.com:nico-swan-com/nvim.git?ref=main&shallow=1";
  };
in
{
  # Import the contents into ~/.config/nvim
  homeDirectory."nvim" = lib.concatStrings [ pkgs.homeDirectory."nvim" repo ];
}

